include("./Funciones/gestorDatosAC.jl")
include("./Funciones/matrizAdmitancia.jl")


function AC_OPF(dLinea::DataFrame, dGen::DataFrame, dNodos::DataFrame, nN::Int, nL::Int, bMVA::Int, solver::String)

    # dLinea    Datos de las líneas
    # dGen      Datos de los generadores
    # dNodos    Datos de los nodos (demanda y voltaje max y min)
    # nN        Número de nodos
    # nL        Número de líneas
    # bMVA      Potencia base
    # solver    Optimizador a utilizar

    ########## GESTIÓN DE DATOS ##########
    # Asignación de los datos con la función "gestorDatosAC"
    P_Cost0, P_Cost1, P_Cost2, P_Gen_lb, P_Gen_ub, Q_Gen_lb, Q_Gen_ub, P_Demand, Q_Demand, Gs, Bs, V_Nodo_lb, V_Nodo_ub, Gen_Status, P_inicial, Q_inicial = gestorDatosAC(dGen, dNodos, nN, bMVA)

    # Matrices de admitancias
    Y = matrizAdmitancia(dLinea, nN, nL)


    ########## INICIALIZAR MODELO ##########
    # Se crea el modelo "m" con la función de JuMP.Model() y tiene como argumento el optimizador "solver"
    # En el caso de elegir Ipopt
    if solver == "Ipopt"
        m = Model(Ipopt.Optimizer)
        set_optimizer_attribute(m, "max_iter", 15000) # Asignación del máximo de iteraciones
        set_optimizer_attribute(m, "tol", 1e-8) # Tolerancia
        set_silent(m) # Se deshabilita las salidas por defecto que tiene el optimizador

    # En caso de elegir Couenne --- Se queda en bucle infinito para problemas medianos/grandes
    elseif solver == "Couenne"
        m = Model(() -> AmplNLWriter.Optimizer(Couenne_jll.amplexe))

    # En caso de que no se encuentre el OPF seleccionado
    else
        println("ERROR: Selección de solver en AC-OPF")

    end


    ########## VARIABLES ##########
    # Asignación de "S_Gen" como variable compleja de la potencia aparente de los generadores de cada nodo
    # Aplicando a la vez las restricciones de mínimo "lower_bound" y máximo "upper_bound" de cada generador
    @variable(m, P_G[i in 1:nN], start = P_inicial[i])
    @variable(m, Q_G[i in 1:nN], start = Q_inicial[i])

    # Asignación de "V" como variable compleja de las tensiones en cada nodo inicializando todos a (1 + j0)V
    @variable(m, V[1:nN], start = 1)
    @variable(m, θ[1:nN], start = 0)


    ########## FUNCIÓN OBJETIVO ##########
    # El objetivo del problema es reducir el coste total que se calcula como ∑cᵢ·Pᵢ
    # Siendo:
    #   cᵢ    Coste del Generador en el nodo i
    #   Pᵢ    Potencia generada del Generador en el nodo i
    @objective(m, Min, sum(P_Cost0[i] + P_Cost1[i] * P_G[i]*bMVA + P_Cost2[i] * (P_G[i]*bMVA)^2 for i in 1:nN))


    ########## RESTRICCIONES ##########
    # Generación mínima y máxima de cada generador
    @constraint(m, [i in 1:nN], P_Gen_lb[i] * Gen_Status[i] <= P_G[i] <= P_Gen_ub[i] * Gen_Status[i])
    @constraint(m, [i in 1:nN], Q_Gen_lb[i] * Gen_Status[i] <= Q_G[i] <= Q_Gen_ub[i] * Gen_Status[i])

    # Límites inferior y superior del módulo de tensión
    @constraint(m, [i in 1:nN], V_Nodo_lb[i] <= V[i] <= V_Nodo_ub[i])

    # Potencia en cada nodo:
    # En la parte izquierda es el balance entre Potencia Generada y Potencia Demandada
    # en caso de ser positivo significa que es un nodo que suministra potencia a la red 
    # y en caso negativo, consume potencia de la red
    # Y en la parte derecha es el sumatorio de todos los flujos que pasan por el nodo
    @constraint(m, [i in 1:nN], P_G[i] - P_Demand[i] == V[i] * sum(V[j] * (real(Y[i, j]) * cos(θ[i] - θ[j]) - imag(Y[i, j]) * sin(θ[i] - θ[j])) for j in 1:nN) + Gs[i])
    @constraint(m, [i in 1:nN], Q_G[i] - Q_Demand[i] == V[i] * sum(V[j] * (real(Y[i, j]) * sin(θ[i] - θ[j]) + imag(Y[i, j]) * cos(θ[i] - θ[j])) for j in 1:nN) + Bs[i])


    # Asignamos un nodo como nodo de referencia (nodo tipo 3 en los datos)
    for i in 1:nrow(dNodos)
        if dNodos.type[i] == 3
            # @constraint(m, V[dNodos.bus_i[i]] == 1) # Esta restricción no se debe usar, pero lo necesitamos para comparar con el caso de validación, de forma que simplifica los cálculos a mano
            @constraint(m, θ[dNodos.bus_i[i]] == 0)
        end
    end


    # Potencia máxima por las línea
    for k in 1:nL
        if dLinea.status[k] != 0
            i = dLinea.fbus[k]
            j = dLinea.tbus[k]

            Pij = V[i] * V[j] * (real(Y[i, j]) * cos(θ[i] - θ[j]) - imag(Y[i, j]) * sin(θ[i] - θ[j])) - V[i]^2 * real(Y[i, j])
            Qij = V[i] * V[j] * (real(Y[i, j]) * sin(θ[i] - θ[j]) + imag(Y[i, j]) * cos(θ[i] - θ[j])) - V[i]^2 * imag(Y[i, j])
            @constraint(m, Pij^2 + Qij^2 <= (dLinea.rateA[k] / bMVA)^2)

            Pji = V[j] * V[i] * (real(Y[j, i]) * cos(θ[j] - θ[i]) - imag(Y[j, i]) * sin(θ[j] - θ[i])) - V[j]^2 * real(Y[j, i])
            Qji = V[j] * V[i] * (real(Y[j, i]) * sin(θ[j] - θ[i]) + imag(Y[j, i]) * cos(θ[j] - θ[i])) - V[j]^2 * imag(Y[j, i])
            @constraint(m, Pji^2 + Qji^2 <= (dLinea.rateA[k] / bMVA)^2)

            @constraint(m, deg2rad(dLinea.angmin[k]) <= θ[i] - θ[j] <= deg2rad(dLinea.angmax[k]))
        end
    end

    ########## RESOLUCIÓN ##########
    JuMP.optimize!(m)    # optimización

    # Guardar solución en DataFrames en caso de encontrar solución óptima (global o local) o se ha llegado al máximo de iteraciones en caso de Ipopt
    if termination_status(m) == OPTIMAL || termination_status(m) == LOCALLY_SOLVED || termination_status(m) == ITERATION_LIMIT

        # solGen recoge los valores de la potencia generada de cada generador de la red
        # Primera columna: nodo
        # Segunda columna: valor real que toma de la variable "S_Gen" (está en pu y se pasa a MVA) del generador de dicho nodo
        # Tercera columna: valor imaginario que toma de la variable "S_Gen" (está en pu y se pasa a MVA) del generador de dicho nodo
        solGen = DataFrames.DataFrame(bus = (dGen.bus), potPGen = (value.(P_G[dGen.bus]) * bMVA), potQGen = (value.(Q_G[dGen.bus]) * bMVA))

        # solFlujos recoge el flujo de potencia que pasa por todas las líneas
        # Primera columna: nodo del que sale
        # Segunda columna: nodo al que llega
        # Tercera columna: valor del flujo de potencia en la línea
        solFlujos = DataFrames.DataFrame(fbus = Int[], tbus = Int[], flujo = Float64[])
        for k in 1:nL
            i = dLinea.fbus[k]
            j = dLinea.tbus[k]
            Pij = V[i] * V[j] * (real(Y[i, j]) * cos(θ[i] - θ[j]) - imag(Y[i, j]) * sin(θ[i] - θ[j])) - V[i]^2 * real(Y[i, j])
            Qij = V[i] * V[j] * (real(Y[i, j]) * sin(θ[i] - θ[j]) + imag(Y[i, j]) * cos(θ[i] - θ[j])) - V[i]^2 * imag(Y[i, j])
            push!(solFlujos, [i, j, round(sqrt(value(Pij^2 + Qij^2)) * bMVA, digits = 3)])
        end

        # solTension recoge el módulo y el desfase de la tensión en los nodos
        # Primera columna: nodo
        # Segunda columna: valor de la tensión en pu
        # Tercera columna: valor del desfase en grados
        solTension = DataFrames.DataFrame(bus = Int[], tensionNodo = Float64[], anguloGrados = Float64[])
        for i in 1:nN
            push!(solTension, Dict(:bus => i, :tensionNodo => round(value(V[i]), digits = 3), :anguloGrados => round(rad2deg(value(θ[i])), digits = 3)))
        end
        # Devuelve como solución el modelo "m" y los DataFrames generados de generación, flujos y ángulos
        return m, solGen, solFlujos, solTension

    # En caso de que no se encuentre solución a la optimización, se mostrará en pantalla el error
    else
        return m, 0, 0, 0
    end

end