# Esta función inicializa todos los solvers para que las próximas veces sean más rápidas

function boot()

    println("Iniciando tests...")
    # Se crea unos DataFrames de una red de 2 buses y una línea que los une
    # La generación se sitúa en el bus 1 y la demanda en el bus 2
    test_linea = DataFrame(fbus = [1], tbus = [2], r = [0], x = [0.1], b = [0], rateA = [10], status = [1])
    test_generador = DataFrame(bus = [1], Pmin = [0], Pmax = [2], Qmin = [0], Qmax = [1], status = [1], c2 = [1], c1 = [1], c0 = [1])
    test_nodos = DataFrame(bus_i = [1, 2], Pd = [0, 1], Qd = [0, 0], Vmax = [1.1, 1.1], Vmin = [0.9, 0.9])

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
