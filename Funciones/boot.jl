# Esta función inicializa todos los solvers para que las próximas veces sean más rápidas

function boot()

    println("Iniciando tests...")
    # Se crea unos DataFrames de una red de 2 buses y una línea que los une
    # La generación se sitúa en el bus 1 y la demanda en el bus 2
    test_linea = DataFrame(F_BUS = [1], T_BUS = [2], R = [0], X = [0.1], BSh = [0], L_SMAX = [10], status = [1])
    test_generador = DataFrame(BUS = [1], P_MIN = [0], P_MAX = [2], Q_MIN = [0], Q_MAX = [1], status = [1], P_COSTE2 = [1], P_COSTE1 = [1], P_COSTE0 = [1])
    test_nodos = DataFrame(BUS = [1, 2], PD = [0, 1], QD = [0, 0], Vmax = [1.1, 1.1], Vmin = [0.9, 0.9])

    # Con esta red simple se genera una los diferentes OPF para que ya estén cargados cuando el usuario los utilice
    println("Test 1...")
    LP_OPF(test_linea, test_generador, test_nodos, 2, 1, 1, "Gurobi")

    limpiarTerminal()

    println("Test1 - Completado")
    println("Test 2...")
    LP_OPF(test_linea, test_generador, test_nodos, 2, 1, 1, "HiGHS")

    limpiarTerminal()

    println("Test 1 - Completado")
    println("Test 2 - Completado")
    println("Test 3...")
    LP_OPF(test_linea, test_generador, test_nodos, 2, 1, 1, "Ipopt")

    limpiarTerminal()

    println("Test 1 - Completado")
    println("Test 2 - Completado")
    println("Test 3 - Completado")
    println("Test 4...")
    AC_OPF(test_linea, test_generador, test_nodos, 2, 1, 1, "Ipopt")

    limpiarTerminal()

    println("Test 1 - Completado")
    println("Test 2 - Completado")
    println("Test 3 - Completado")
    println("Test 4 - Completado")
    println("Test 5...")
    AC_OPF(test_linea, test_generador, test_nodos, 2, 1, 1, "Couenne")

    limpiarTerminal()
    
    println("Test 1 - Completado")
    println("Test 2 - Completado")
    println("Test 3 - Completado")
    println("Test 4 - Completado")
    println("Test 5 - Completado")
    sleep(1)
    
end
