# Esta función precompila todos los solvers para que ya estén cargados durante la ejecución del caso

function boot()

    limpiarTerminal()

    println("Iniciando tests...")
    # Se extrae los datos del sistema_test
    test_linea = CSV.read("Funciones/sistema_test/datosLineas.csv", DataFrame)
    test_generador = CSV.read("Funciones/sistema_test/datosGeneradores.csv", DataFrame)
    test_nodos = CSV.read("Funciones/sistema_test/datosNodos.csv", DataFrame)
    # Con esta red simple se genera una los diferentes OPF para que ya estén cargados cuando el usuario los utilice
    
    println("Test 1...")
    LP_OPF(test_linea, test_generador, test_nodos, 2, 1, 100, "Gurobi")

    limpiarTerminal()

    println("Test 1 - Completado")
    println("Test 2...")
    LP_OPF(test_linea, test_generador, test_nodos, 2, 1, 100, "HiGHS")

    limpiarTerminal()

    println("Test 1 - Completado")
    println("Test 2 - Completado")
    println("Test 3...")
    LP_OPF(test_linea, test_generador, test_nodos, 2, 1, 100, "Ipopt")
    rutaM = "Funciones/sistema_test/sistema_test.m"
    solve_opf(rutaM, DCMPPowerModel, Ipopt.Optimizer)

    limpiarTerminal()

    println("Test 1 - Completado")
    println("Test 2 - Completado")
    println("Test 3 - Completado")
    println("Test 4...")
    AC_OPF(test_linea, test_generador, test_nodos, 2, 1, 100, "Ipopt")

    limpiarTerminal()

    println("Test 1 - Completado")
    println("Test 2 - Completado")
    println("Test 3 - Completado")
    println("Test 4 - Completado")
    println("Test 5...")
    AC_OPF(test_linea, test_generador, test_nodos, 2, 1, 100, "Couenne")

    limpiarTerminal()
    
    println("Test 1 - Completado")
    println("Test 2 - Completado")
    println("Test 3 - Completado")
    println("Test 4 - Completado")
    println("Test 5 - Completado")
    sleep(1)
    
end
