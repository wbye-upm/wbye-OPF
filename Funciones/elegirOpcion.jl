# Bucle que duvuelve la opción que usuario elija una vez confirmado la elección

function elegirOpcion(o::Vector{String}, tipo::String)

    # Inicialización de las variables
    valido = false  # Es la variable designada para ver si la elección es válida, si se da el caso se vuelve true
    seleccion = 0   # Es la opción elegida por el usuario

    # El bucle sigue hasta que la respuesta sea valido
    while !valido 

        # Entra en un bloque try-catch para poder manejar las entradas que provocan excepciones en el sistema
        try

            # Limpia el terminal
            limpiarTerminal()

            # Imprimir en el terminal las posibles opciones enumeradas
            for (i, k) in enumerate(o)
                println("$i. $k")
            end

            # Pregunta al usuario que introduzca en el terminal su opción
            println("\nElije el número del ", tipo, " que quiera utilizar: ")
            seleccion = parse(Int, readline())

            # Si la entrada es un número y está dentro del rango de las posibles opciones
            if seleccion >= 1 && seleccion <= length(o)

                # Limpia el terminal
                limpiarTerminal()

                # Muestra en el terminal la oción seleccionada
                println("Ha elegido la opción:\n", seleccion, ". ", o[seleccion])

                # Pregunta si quiere confirmar la elección
                println("\nPulsa la tecla ENTER para continuar o cualquier otra entrada para volver a elegir.")
                confirmar = readline()
                
                # En caso de que la entrada sea la tecla ENTER
                if confirmar == ""
                    # Actualiza el valor de "valido" para salir del bucle
                    valido = true

                # En caso contrario
                else
                    # Se ignora la entrada y se vuelve a empezar el bucle
                    continue

                end

            # En caso de que el número introducido esté fuera de rango
            else

                # Limpia el terminal
                limpiarTerminal()

                # Muestra mensaje en el terminal para indicar el rango
                println("Por favor, introduzca un número entre 1 y $(length(o)).")

                # El mensaje se muestra en pantalla por 2 segundos
                sleep(1)
                continue

            end

        # En caso de que la entrada cause una excepción, 
        # por ejemplo introduciendo una letra al cual no se puede convertir en un int
        catch

            # Limpia el terminal
            limpiarTerminal()

            # El mensaje se muestra en pantalla por 2 segundos
            println("Entrada no válida. Por favor, introduzca un número.")
            sleep(1)
            continue

        end

    end

    # Devuelve la opción seleccionada por el usuario
    return o[seleccion]
    
end