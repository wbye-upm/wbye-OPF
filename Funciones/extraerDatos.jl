function extraerDatos(c::String)
    # Datos de las lineas
    datosLinea = CSV.read("Casos/$c/datosLineas.csv", DataFrame)

    # Datos de los generadores
    datosGenerador = CSV.read("Casos/$c/datosGeneradores.csv", DataFrame)

    # Datos de la demanda
    datosNodo = CSV.read("Casos/$c/datosNodos.csv", DataFrame)

    # Número de nodos
    nNodos = maximum([datosLinea.F_BUS; datosLinea.T_BUS])

    # Número de líneas
    nLineas = size(datosLinea, 1)

    # Potencia base
    bMVA = 100

    # Devuelve todos los DataFrames y variables generadas
    return(datosLinea, datosGenerador, datosNodo, nNodos, nLineas, bMVA)
end