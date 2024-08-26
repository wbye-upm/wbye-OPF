# Esta funcion crea la matriz de admitancias Y con los datos de las líneas

function matrizAdmitancia(datos::DataFrame, nn::Int, nl::Int)

    # datos:    DataFrame de las líneas
    # nn:       Número de nodos
    # nl:       Número de líneas

    # A partir de los datos de los extremos de cada línea (fbus y tbus) se crea la matriz de incidencia
    # donde se asigna 1 a los nodos fbus y -1 a los nodos tbus
    # Para más información consultar: https://en.wikipedia.org/wiki/Incidence_matrix
    # Para la función sparse de SparseArrays los argumentos son
    # sparse([Índices de Filas], [Índices de Columnas], [Valor], [Número de Filas totales], [Número de Columnas totales])
    A = SparseArrays.sparse(datos.fbus, 1:nl, 1, nn, nl) + SparseArrays.sparse(datos.tbus, 1:nl, -1, nn, nl)
    
    # De los datos de las líneas obtenemos la resistencia "datos.r" y reactancia "datos.x" y se suman en Z = r + jX
    Z = (datos.r .+ im .* datos.x)
    Y_0 = datos.status ./ Z
    # A partir del valor de los valores de impedancia "Z" se crea el la matriz de admitancias "Y"
    Y = A * SparseArrays.spdiagm(Y_0) * A'
    # Donde spdiagm crea una matriz sin elementos (SparseArray) y asigna los valores de cada "1/Z" en la diagonal principal

    # Se devuelve la matriz de admitancia total, la de admitancias de línea y la de admitancias shunt
    return Y

end