function gestorDatosLP(Generador::DataFrame, Demanda::DataFrame, nn::Int, bMVA::Int)

    # El Dataframe introducido como argumento "dGen" en "Generador" contiene los datos de los generadores sacado de su correspondiente archivo "datosGeneradores.csv"
    # R = sparsevec(I, V, n) se crea la lista "R" cuyos índices es el vector "I" y los valores es el vector "V", 
    # cuyo tamaño total es de "n" elementos. Es decir, R[I[k]] = V[k] para k <= n
    # P_Cost es un sparsevec de "nn" elementos que recoge como 
        # Ínidices: nodo en el que están los generadores "Generador.BUS"
        # Valores: coste de los respectivos generadores "Generador.P_COSTE"
    # Esto significa que la lista vacía de "nn" elementos se va llenando con los valores del coste en las posiciones del bus correspondiente
    # Por ejemplo: Si hay un generador en el bus 3 que cuesta 10€/MWh, la lista para los elementos 1 y 2 sigen vacíos y el elemento 3 se le asigna un 10
    P_Cost0 = SparseArrays.sparsevec(Generador.BUS, Generador.P_COSTE0, nn)
    P_Cost1 = SparseArrays.sparsevec(Generador.BUS, Generador.P_COSTE1, nn)
    P_Cost2 = SparseArrays.sparsevec(Generador.BUS, Generador.P_COSTE2, nn)

    # P_Gen_lb y P_Gen_ub son sparsevec de "nn" elementos de los limites inferior y superior, respectivamente, de la potencia activa de los gerneradores
        # Índices: nodo donde está el generador "Generador.BUS"
        # Valores: límite inferior "Generador.P_MIN" o superior "Generador.P_MAX" del generador
    P_Gen_lb = SparseArrays.sparsevec(Generador.BUS, Generador.P_MIN/bMVA, nn)
    P_Gen_ub = SparseArrays.sparsevec(Generador.BUS, Generador.P_MAX/bMVA, nn)

    # En los datos de los generadores se tiene en cuenta generadores que no están activos con status = 0
    # Por lo que se crea un sparsevec que contenga estos valores para considerar generadores apagados
    Gen_Status = SparseArrays.sparsevec(Generador.BUS, Generador.status, nn)

    # El Dataframe introducido como argumento "dDem" en "Demanda" contiene los datos de la demanda sacado de su correspondiente archivo "datosNodos.csv"
    # P_Demand es un sparsevec de "nn" elementos donde se recoge como 
        # Índices: nodos donde está la demanda "Demanda.BUS"
        # Valores: demanda en los respectivos nodos "Demanda.PD"
    P_Demand = SparseArrays.sparsevec(Demanda.BUS, Demanda.PD/bMVA, nn)

    # Se devuelve como resultado de la función todos los SparseArrays generados
    return P_Cost0, P_Cost1, P_Cost2, P_Gen_lb, P_Gen_ub, Gen_Status, P_Demand

end