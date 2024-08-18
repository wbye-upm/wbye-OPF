function gestorDatosLP(Generador::DataFrame, Nodo::DataFrame, nn::Int, bMVA::Int)

    # Generador:    DataFrame de los generadores
    # Nodo:         DataFrame de los nodos
    # nn:           Número de nodos
    # bMVA:         Potencia base

    # El Dataframe introducido como argumento "Generador" contiene los datos de los generadores sacado de su correspondiente archivo "datosGeneradores.csv"
    # Explicación del sparsevec:
    # r = sparsevec(I, V, n) se crea la lista "r" cuyos índices es el vector "I" y los valores es el vector "V", 
    # cuyo tamaño total es de "n" elementos. Es decir, r[I[k]] = V[k] para k <= n
    
    # P_Cost es un sparsevec de "nn" elementos que recoge como 
        # Ínidices: nodo en el que están los generadores "Generador.bus"
        # Valores: coste de los respectivos generadores
    # Esto significa que la lista vacía de "nn" elementos se va llenando con los valores del coste en las posiciones del bus correspondiente
    # Por ejemplo: Si hay un generador en el bus 3 que cuesta 10€/MWh, la lista para los elementos 1 y 2 sigen vacíos y el elemento 3 se le asigna un 10
    P_Cost0 = SparseArrays.sparsevec(Generador.bus, Generador.c0, nn)
    P_Cost1 = SparseArrays.sparsevec(Generador.bus, Generador.c1, nn)
    P_Cost2 = SparseArrays.sparsevec(Generador.bus, Generador.c2, nn)

    # P_Gen_lb y P_Gen_ub son sparsevec de "nn" elementos de los limites inferior y superior, respectivamente, de la potencia activa de los gerneradores
        # Índices: nodo donde está el generador "Generador.bus"
        # Valores: límite inferior "Generador.Pmin" o superior "Generador.Pmax" del generador
    P_Gen_lb = SparseArrays.sparsevec(Generador.bus, Generador.Pmin / bMVA, nn)
    P_Gen_ub = SparseArrays.sparsevec(Generador.bus, Generador.Pmax / bMVA, nn)

    # En los datos de los generadores se tiene en cuenta generadores que no están activos con status = 0
    # Por lo que se crea un sparsevec que contenga estos valores para considerar generadores apagados
    Gen_Status = SparseArrays.sparsevec(Generador.bus, Generador.status, nn)

    # El Dataframe introducido como argumento "Nodo" contiene los datos de la demanda sacado de su correspondiente archivo "datosNodos.csv"
    # P_Demand es un sparsevec de "nn" elementos donde se recoge como 
        # Índices: nodos donde está la demanda "Nodo.bus_i"
        # Valores: demanda en los respectivos nodos "Nodo.Pd"
    P_Demand = SparseArrays.sparsevec(Nodo.bus_i, Nodo.Pd / bMVA, nn)

    # Se devuelve como resultado de la función todos los SparseArrays generados
    return P_Cost0, P_Cost1, P_Cost2, P_Gen_lb, P_Gen_ub, Gen_Status, P_Demand

end