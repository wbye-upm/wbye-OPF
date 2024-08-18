# Esta funcion crea la matriz de susceptancia B con los datos de las líneas

function matrizSusceptancia(datos::DataFrame, nn::Int, nl::Int)

    # datos:    DataFrame de las líneas
    # nn:       Número de nodos
    # nl:       Número de líneas

    # A partir de los datos de los extremos de cada línea (fbus y tbus) se crea la matriz de incidencia
    # donde asignamos 1 a los nodos fbus y -1 a los nodos tbus
    # Para más información consultar: https://en.wikipedia.org/wiki/Incidence_matrix
    # Para la función sparse de SparseArrays los argumentos son
    # sparse([Índices de Filas], [Índices de Columnas], [Valor], [Número de Filas totales], [Número de Columnas totales])
    A = SparseArrays.sparse(datos.fbus, 1:nl, 1, nn, nl) + SparseArrays.sparse(datos.tbus, 1:nl, -1, nn, nl)

    # Se crea un vector con los valores de la susceptancia de cada línea B = -1/x
    B = - 1 ./ (datos.x) .* datos.status

    # Una vez teniendo la Matriz de Incidencia "A" y el vector de Susceptancias "B"
    # Se puede crear la Matriz de Susceptancia "B_0":
    B_0 = A * SparseArrays.spdiagm(B) * A'
    # Donde spdiagm crea una matriz sin elementos (SparseArray) y asigna los elementos del vector B en la diagonal principal
    
    # Se devuelve la matriz susceptancia
    return B_0

end