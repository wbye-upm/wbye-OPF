# Esta función gestiona la variable del modelo y los DataFrames de la solución de la Optimización

function gestorResultados(modelo, solGeneradores, solFlujos, solAngulos)

    # modelo: El modelo que se ha creado para optimizar
    # solGeneradores: DataFrame con la solución de los generadores
    # solFlujos: DataFrame con la solución de los flujos
    # solAngulos: DataFrame con la solución de los ángulos

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
        
        # Comprueba el número de files de los DataFrames de la solución
        genFilas = DataFrames.nrow(solGeneradores);
        flFilas = DataFrames.nrow(solFlujos);
        angFilas = DataFrames.nrow(solAngulos);

        # Asigna el número máximo de filas que se puede mostrar
        nmax = 10

        # En caso de que no se supere el máximo de filas asignado
        if genFilas <= nmax && flFilas <= nmax && angFilas <= nmax

            # Pregunta al usuario si quiere tener los resultados en el terminal
            println("\n¿Quiere imprimir por el terminal el resultado?")
            println("Pulsa la tecla ENTER para confirmar o cualquier otra entrada para negar")
            mostrarTerminal = readline(stdin)

            # En caso que pulse la tecla ENTER
            if mostrarTerminal == ""

                # Muestra las tablas de la solución en el terminal
                println("Solución de los generadores:")
                DataFrames.show(solGeneradores, allrows = true, allcols = true)
                println("\n\nSolución de los flujos:")
                DataFrames.show(solFlujos, allrows = true, allcols = true)
                println("\n\nSolución de los ángulos:")
                DataFrames.show(solAngulos, allrows = true, allcols = true)

            # En caso de que introduzca cualquier otra entrada
            else
                println("\nNo se imprimirá el resultado")

            end
        
        # En caso de que se supere el máximo de filas en alguno de los DataFrames
        else
            println("\nLas tablas son demasiado grandes para imprimir por el terminal")

        end
        
        # Imprime en pantalla el coste final que se obtiene tras la optimización
        println("\n\nCoste final: ", round(objective_value(modelo), digits = 2), " €/h")

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
                CSV.write("./Resultados/solAngulos.csv", solAngulos, delim = ";")
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