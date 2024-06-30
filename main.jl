##### Explicar por qué no se puede comparar los casos grandes (zonas de tensión)
#### Si no se puede comparar AC, no mencionar DC

# Se carga todas las librerías
include("./Funciones/cargarLibrerias.jl")

# Se carga las funciones
include("./Funciones/cargarFunciones.jl")

# Se inicializa el programa con diferentes test
# principalmente para cargar los solvers y resolver con mayor rapidez el caso pedido por el usuario
boot()

# Cariable para salir del bucle
finPrograma = false
# En caso de que no sea fin de programa
while !finPrograma

    # Limpiza del terminal
    limpiarTerminal()

    # Se entra en un bucle para que el usuario seleccione el caso que se quiere estudiar
    casoEstudio, opfTipo, s = selectEstudio()

    # Limpiza del terminal
    limpiarTerminal()

    # Se extrae los datos del caso de estudio
    # Donde:
        # datos[1] = datos de las líneas
        # datos[2] = datos de los generadores
        # datos[3] = datos de la demanda
        # datos[4] = número de nodos
        # datos[5] = número de líneas
    println("\nExtrayendo datos...")
    datos = extraerDatos(casoEstudio)
    println("Datos extraídos.")

    # Una vez elegido el caso de estudio se llama a la función correspondiente para realizar el cálculo del problema de optimización
    println("\nGenerando OPF...")
    # En caso de un LP-OPF
    if opfTipo == "LP-OPF"
        m, solGen, solFlujos, solAngulos = LP_OPF(datos[1], datos[2], datos[3], datos[4], datos[5], datos[6], s)

    # En caso de un AC-OPF
    elseif opfTipo == "AC-OPF"
        # ##### Revisión
        m, solGen, solFlujos, solAngulos = AC_OPF(datos[1], datos[2], datos[3], datos[4], datos[5], datos[6], s)

    # Si se llega hasta este punto y no se da ningún caso anterior, devuelve un error
    else
        println("ERROR: Fallo en cargar el tipo de OPF")

    end

    # Limpieza del terminal
    limpiarTerminal()

    # Gensión de los resultados de optimización
    println("Problema resuelto")
    gestorResultados(m, solGen, solFlujos, solAngulos)

    # Preguntar al usuario si quiere continuar en el bucle para estudiar otro caso
    println("\nPulsa la tecla ENTER para continuar o cualquier otra entrada para salir.")
    if readline() == ""
        # Se mantiene la variable en falso para continuar en el bucle
        finPrograma = false
    else
        # Actualización de la variable para salir del bucle
        finPrograma = true
        exit()
    end

end