# Esta función gestiona la variable del modelo y los DataFrames de la solución de la Optimización

function gestorResultados(modelo, solGeneradores, solFlujos, solTension, rutaM, opfTipo, solver)

    # modelo: El modelo que se ha creado para optimizar
    # solGeneradores: DataFrame con la solución de los generadores
    # solFlujos: DataFrame con la solución de los flujos
    # solTension: DataFrame con la solución de la tensión (módulo y argumento)

    # Limpieza del terminal
    limpiarTerminal()

    # Mostrar resultados en caso de que la optimización se haya realizado de forma exitosa, tanto de forma global como local, o si se ha llegado al máximo de iteraciones
    if termination_status(modelo) == OPTIMAL || termination_status(modelo) == LOCALLY_SOLVED || termination_status(modelo) == ITERATION_LIMIT

        # En caso de solución global
        if termination_status(modelo) == OPTIMAL
            println("Solución óptima encontrada")

        # En caso de solución local
        elseif termination_status(modelo) == LOCALLY_SOLVED
            println("Solución local encontrada")

        # En caso de haber llegado al máximo de iteraciones
        elseif termination_status(modelo) == ITERATION_LIMIT
            println("Límite de iteraciones alcanzado")

        end

        ##### Con el terminal de VS Code no hace display del plot pero con el terminal de Julia sí
        # # Preguntar al usuario si quiere ver el sistema eléctrico
        # # En caso de que la ruta exista
        solucion = 0
        if rutaM != "None"
            # Mostrar gráficamente la red
            # caso = parse_file(rutaM)

            # println("\n¿Quiere ver gráficamente la red eléctrica seleccionada?")
            # println("Pulsa la tecla ENTER para confirmar o cualquier otra entrada para negar")
            # verGrafica = readline(stdin)
            # if verGrafica == ""
            #     # Con el paquete de PowerPlots.jl se representa el sistema
            #     powerplot(caso)

            # else
            #     println("\nNo se mostrará gráficamente")
            # end

            # En caso de querer resolver un LP_OPF
            if opfTipo == "LP-OPF"
                # Usando Gurobi
                if solver == "Gurobi"
                    solucion = solve_opf(rutaM, DCMPPowerModel, Gurobi.Optimizer)
                # Usando HiGHS
                elseif solver == "HiGHS"
                    solucion = solve_opf(rutaM, DCMPPowerModel, HiGHS.Optimizer)
                # Usando Ipopt
                elseif solver == "Ipopt"
                    solucion = solve_opf(rutaM, DCMPPowerModel, Ipopt.Optimizer)
                # Error
                else
                    print("Error al cargar la resolución DC por PowerModels")
                end

            # En caso de querer resolver un AC_OPF
            elseif opfTipo == "AC-OPF"
                # Usando Ipopt
                if solver == "Ipopt"
                    solucion = solve_opf(rutaM, ACRPowerModel, Ipopt.Optimizer)
                # Error
                else
                    print("Error al cargar la resolución AC por PowerModels")
                end

            # En caso de error
            else
                println("Error al cargar el tipo de solver en PowerModels")
            end

            limpiarTerminal()

        # En caso de que la ruta no exista
        else
            println("Archivo del caso .m no encontrado\n")
        end
        
        # Comprueba el número de filas de los DataFrames de la solución

        genFilas = DataFrames.nrow(solGeneradores);
        flFilas = DataFrames.nrow(solFlujos);
        angFilas = DataFrames.nrow(solTension);

        # Asigna el número máximo de filas que se puede mostrar
        nmax = 10

        # En caso de que no se supere el máximo de filas asignado
        if genFilas <= nmax && flFilas <= nmax && angFilas <= nmax

            # Pregunta al usuario si quiere tener los resultados en el terminal
            println("\n¿Quiere imprimir por el terminal el resultado?")
            println("Pulsa la tecla ENTER para confirmar o cualquier otra entrada para negar")
            mostrarTerminal = readline(stdin)

            limpiarTerminal()

            # En caso que pulse la tecla ENTER
            if mostrarTerminal == ""

                # Muestra las tablas de la solución en el terminal
                println("Solución de los generadores:")
                DataFrames.show(solGeneradores, allrows = true, allcols = true)
                println("\n\nSolución de los flujos:")
                DataFrames.show(solFlujos, allrows = true, allcols = true)
                println("\n\nSolución de los ángulos:")
                DataFrames.show(solTension, allrows = true, allcols = true)

                println("") # Linea de separación

            # En caso de que introduzca cualquier otra entrada
            else
                println("\nNo se imprimirá el resultado")

            end
        
        # En caso de que se supere el máximo de filas en alguno de los DataFrames
        else
            println("Las tablas son demasiado grandes para imprimir por el terminal")

        end

        # Se imprime la solución obtenida en caso de utilizar el paquete PowerModels.jl
        # En caso que exista el archivo .m
        if solucion != 0
            println("Coste final obtenido en PowerModels: ", round(solucion["objective"], digits = 2), "€/h")
            println("Tiempo de ejecución del programa: ", solucion["solve_time"] * 1000, " ms")
        end

        # Imprime en pantalla el coste final que se obtiene tras la optimización
        println("\nCoste final con el programa: ", round(objective_value(modelo), digits = 2), " €/h")
        println("Tiempo de ejecución del programa: ", solve_time(modelo) * 1000, " ms")
        # Pregunta al usuario si quiere guardar los datos en un CSV
        println("\n¿Quiere guardar el resultado en un archivo CSV?")
        println("Pulsa la tecla ENTER para confirmar o cualquier otra entrada para negar")
        guardarCSV = readline(stdin)

        # En caso de que pulse la tecla ENTER
        if guardarCSV == ""

            # Pregunta al usuario si realmente quiere guardar debido a que se sobreescribirá en el fichero existente
            println("Si guardas en CSV se van a borrar los datos guardados anteriormente")
            println("¿Estás seguro de que quieres guardar?")
            println("\nPulsa la tecla ENTER para confirmar o cualquier otra entrada para negar")
            confirmarGuardarCSV = readline(stdin)

            # En caso de que pulse la tecla ENTER
            if confirmarGuardarCSV == ""

                # Guarda en los correspondientes ficheros los resultados obtenidos
                CSV.write("./Resultados/solTension.csv", solTension, delim = ";")
                CSV.write("./Resultados/solFlujosLineas.csv", solFlujos, delim = ";")
                CSV.write("./Resultados/solGeneradores.csv", solGeneradores, delim = ";")
                println("\nEl resultado se ha guardado en ./Resultados")
            
            # En caso de que introduzca cualquier otra entrada
            else
                println("\nNo se guardará el resultado")

            end

        # En caso de que se introduzca cualquier otra entrada no se guarda el resultado 
        else
            println("\nNo se guardará el resultado")
            
        end
    
    # En caso de que no se llega a una solución óptima del problema
    else
        # Imprime en el terminal la causa de la finalización de la optimización
        println("ERROR: ", termination_status(modelo))

    end

end