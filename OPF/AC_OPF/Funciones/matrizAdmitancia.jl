#### Indicar referencia a Spiros (link) y las diferencias

function matrizAdmitancia(d::DataFrame, nn::Int, nl::Int)

    # A partir de los datos de los extremos de cada línea (F_BUS y T_BUS) se crea la matriz de incidencia
    # donde se asigna 1 a los nodos F_BUS y -1 a los nodos T_BUS
    # Para más información consultar: https://en.wikipedia.org/wiki/Incidence_matrix
    # Para la función sparse de SparseArrays los argumentos son
    # sparse([Índices de Filas], [Índices de Columnas], [Valor], [Número de Filas totales], [Número de Columnas totales])
    A = SparseArrays.sparse(d.F_BUS, 1:nl, 1, nn, nl) + SparseArrays.sparse(d.T_BUS, 1:nl, -1, nn, nl)
    
    # De los datos de las líneas obtenemos la resistencia "d.R" y reactancia "d.X" y se suman en Z = R + jX
    Z = (d.R .+ im * d.X)
    # A partir del valor de los valores de impedancia "Z" se crea el la matriz de admitancias "Y"
    Y = A * SparseArrays.spdiagm(1 ./ Z) * A'
    # Donde spdiagm crea una matriz sin elementos (SparseArray) y asigna los valores de cada "1/Z" en la diagonal principal

    # Se calcula la admitancia shunt como la mitad del valor de "d.Sh"
    y_Sh = 0.5 * (im * d.BSh)
    Y_Sh = SparseArrays.spdiagm(LinearAlgebra.diag(A * SparseArrays.spdiagm(y_Sh) * A'))

    # Se devuelve la matriz de admitancia total, la de admitancias de línea y la de admitancias shunt
    return Y + Y_Sh, Y, Y_Sh

end