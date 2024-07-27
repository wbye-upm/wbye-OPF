#### Indicar referencia a Spiros (link) y las diferencias

function matrizAdmitancia(d::DataFrame, nn::Int, nl::Int, bMVA::Int)

    # A partir de los datos de los extremos de cada línea (fbus y tbus) se crea la matriz de incidencia
    # donde se asigna 1 a los nodos fbus y -1 a los nodos tbus
    # Para más información consultar: https://en.wikipedia.org/wiki/Incidence_matrix
    # Para la función sparse de SparseArrays los argumentos son
    # sparse([Índices de Filas], [Índices de Columnas], [Valor], [Número de Filas totales], [Número de Columnas totales])
    A = SparseArrays.sparse(d.fbus, 1:nl, 1, nn, nl) + SparseArrays.sparse(d.tbus, 1:nl, -1, nn, nl)
    
    # De los datos de las líneas obtenemos la resistencia "d.r" y reactancia "d.x" y se suman en Z = r + jX
    Z = ((d.r / bMVA) .+ im * (d.x / bMVA))
    # A partir del valor de los valores de impedancia "Z" se crea el la matriz de admitancias "Y"
    Y = A * SparseArrays.spdiagm(1 ./ Z) * A'
    # Donde spdiagm crea una matriz sin elementos (SparseArray) y asigna los valores de cada "1/Z" en la diagonal principal

    # Se calcula la admitancia shunt como la mitad del valor de "d.Sh"
    y_Sh = 0.5 * (im * d.b / bMVA)
    # Y_Sh = SparseArrays.spdiagm(LinearAlgebra.diag(A * SparseArrays.spdiagm(y_Sh) * A'))
    Y_Sh = A * SparseArrays.spdiagm(y_Sh) * A'

    # Se devuelve la matriz de admitancia total, la de admitancias de línea y la de admitancias shunt
    return Y, Y_Sh

end