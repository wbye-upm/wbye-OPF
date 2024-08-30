include("./Funciones/gestorDatosLP.jl")
include("./Funciones/matrizSusceptancia.jl")

function LP_OPF(dLinea::DataFrame, dGen::DataFrame, dNodos::DataFrame, nN::Int, nL::Int, bMVA::Int, solver::String) 

    # dLinea:   Datos de las líneas
    # dGen:     Datos de los generadores
    # dNodos:   Datos de la demanda
    # nN:       Número de nodos
    # nL:       Número de líneas
    # bMVA:     Potencia base
    # solver:   Solver a utilizar

    ########## GESTIÓN DE DATOS ##########
    P_Cost0, P_Cost1, P_Cost2, P_Gen_lb, P_Gen_ub, Gen_Status, P_Demand = gestorDatosLP(dGen, dNodos, nN, bMVA)
    
    # Matriz de susceptancias de las líneas
    B = matrizSusceptancia(dLinea, nN, nL)
    

    ########## INICIALIZAR MODELO ##########
    # Se crea el modelo "m" con la función de JuMP.Model() y
    # tiene como argumento el optimizador usado, en este caso, el solver Gurobi
    if solver == "Gurobi"
        m = Model(Gurobi.Optimizer)
        # Se deshabilita las salidas por defecto que tiene el optimizador
        set_silent(m)

    # Para el solver HiGHS
    elseif solver == "HiGHS"
        m = Model(HiGHS.Optimizer)
        # Se deshabilita las salidas por defecto que tiene el optimizador
        set_silent(m)

    # Para el solver Ipopt
    elseif solver == "Ipopt"
        m = Model(Ipopt.Optimizer)
        # Se deshabilita las salidas por defecto que tiene el optimizador
        set_silent(m)
    
    # En caso de error
    else
        println("ERROR: Selección de solver en DC-OPF")
    
    end

    ########## VARIABLES ##########
    # Se asigna una variable de generación para todos los nodos y se le asigna un valor inicial de 0 
    @variable(m, P_G[i in 1:nN], start = 0)

    # Se considera que el módulo del voltaje en todos los nodos es la unidad y es invariante, V = 1
    # Lo único que varía es el ángulo
    @variable(m, θ[1:nN], start = 0)


    ########## FUNCIÓN OBJETIVO ##########
    # El objetivo del problema es reducir el coste total que se calcula como ∑cᵢ·Pᵢ
    # Siendo:
    #   cᵢ el coste del Generador en el nodo i
    #   Pᵢ la potencia generada del Generador en el nodo i
    @objective(m, Min, sum(P_Cost0[i] + P_Cost1[i] * P_G[i]*bMVA + P_Cost2[i] * (P_G[i]*bMVA)^2 for i in 1:nN))


    ########## RESTRICCIONES ##########
    # Restricción de flujo de potencia entre los nodos: P_G[i] - P_Demand[i] = ∑(B[i,j] · (θ[i] - θ[j]))
    # Siendo 
    #   P_G[i] la potencia generada en el nodo i
    #   P_Demand[i] la potencia demandada en el nodo i
    #   B[i,j] susceptancia de la linea que conecta los nodos i - j
    #   θ[i] - θ[j] la diferencia de ángulos entre los nodos i - j
    # En la parte izquierda es el balance entre Potencia Generada y Potencia Demandada
    # en caso de ser positivo significa que es un nodo que suministra potencia a la red 
    # y en caso negativo, consume potencia de la red
    # Y en la parte derecha es el sumatorio de todos los flujos que pasan por el nodo
    @constraint(m, [i in 1:nN], P_G[i] - P_Demand[i] == sum(B[i, j] * (θ[i] - θ[j]) for j in 1:nN))

    # Diferencia de ángulos máximo entre dos nodos conectados por una línea k
    for k in 1:nL
        if dLinea.status[k] != 0
            @constraint(m, deg2rad(dLinea.angmin[k]) <= θ[dLinea.fbus[k]] - θ[dLinea.tbus[k]] <= deg2rad(dLinea.angmax[k]))
        end
    end

    # Potencia máxima por las líneas considerando el estado de la línea
    # La potencia que circula en la linea que conecta los nodos i-j: Pᵢⱼ = Bᵢⱼ·(θᵢ-θⱼ) 
    # Su valor abosoluto debe ser menor que el dato de potencia max en dicha línea "dLinea.rateA"
    for i in 1:nL
        if dLinea.status[i] != 0
            @constraint(m, -dLinea.rateA[i] / bMVA <= B[dLinea.fbus[i], dLinea.tbus[i]] * (θ[dLinea.fbus[i]] - θ[dLinea.tbus[i]]) <= dLinea.rateA[i] / bMVA)
        end
    end

    # Potencia mínima y máxima de los generadores considerando el estado del generador
    @constraint(m, [i in 1:nN], P_Gen_lb[i] * Gen_Status[i] <= P_G[i] <= P_Gen_ub[i] * Gen_Status[i])

    # Se selecciona un nodo como refenrecia (tipo de nodo = 3)
    # Necesario en caso de HiGHS para evitar un bucle infinito al resolver la optimización
    for i in 1:nrow(dNodos)
        if dNodos.type[i] == 3
            @constraint(m, θ[dNodos.bus_i[i]] == 0)
        end
    end

    ########## RESOLUCIÓN ##########
    JuMP.optimize!(m) # Optimización

    # Guardar solución en DataFrames en caso de encontrar solución óptima
    if termination_status(m) == OPTIMAL || termination_status(m) == LOCALLY_SOLVED || termination_status(m) == ITERATION_LIMIT

        # solGen recoge los valores de la potencia generada de cada generador de la red
        # Primera columna: nodo
        # Segunda columna: valor lo toma de la variable "P_G" (está en pu y se pasa a MVA) del generador de dicho nodo
        solGen = DataFrames.DataFrame(bus = (dGen.bus), potenciaGen = (value.(P_G[dGen.bus]) * bMVA))

        # solFlujos recoge el flujo de potencia que pasa por todas las líneas
        # Primera columna: nodo del que sale
        # Segunda columna: nodo al que llega
        # Tercera columna: valor del flujo de potencia en la línea
        solFlujos = DataFrames.DataFrame(fbus = Int[], tbus = Int[], flujo = Float64[])
        # El flujo por la línea que conecta los nodos i-j es igual de la susceptancia de la línea por la diferencia de ángulos entre los nodos i-j
        # Pᵢⱼ = Bᵢⱼ · (θᵢ - θⱼ)
        for i in 1:nL
            if value(B[dLinea.fbus[i], dLinea.tbus[i]] * (θ[dLinea.fbus[i]] - θ[dLinea.tbus[i]])) > 0
                push!(solFlujos, Dict(:fbus => (dLinea.fbus[i]), :tbus => (dLinea.tbus[i]), :flujo => round(value(B[dLinea.fbus[i], dLinea.tbus[i]] * (θ[dLinea.fbus[i]] - θ[dLinea.tbus[i]])) * bMVA, digits = 3)))
            elseif value(B[dLinea.fbus[i], dLinea.tbus[i]] * (θ[dLinea.fbus[i]] - θ[dLinea.tbus[i]])) != 0
                push!(solFlujos, Dict(:fbus => (dLinea.tbus[i]), :tbus => (dLinea.fbus[i]), :flujo => round(value(B[dLinea.tbus[i], dLinea.fbus[i]] * (θ[dLinea.tbus[i]] - θ[dLinea.fbus[i]])) * bMVA, digits = 3)))
            end
        end

        # solTension recoge el módulo y el argumento de la tensión
        # Primera columna: nodo
        # Segunda columna: módulo de la tensión (1)
        # Tercera columna: valor del desfase en grados
        solTension = DataFrames.DataFrame(bus = Int[], tensionNodo = Float64[], anguloGrados = Float64[])
        for i in 1:nN
            push!(solTension, Dict(:bus => i, :tensionNodo => 1,:anguloGrados => round(rad2deg(value(θ[i])), digits = 3)))
        end

        # Devuelve como solución el modelo "m" y los DataFrames generados de generación, flujos y ángulos
        return m, solGen, solFlujos, solTension

    # En caso de que no se encuentre solución a la optimización, se mostrará en pantalla el error
    else
        return m, 0, 0, 0
        
    end

end