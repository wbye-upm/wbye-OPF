function gestorDatosAC(Generador::DataFrame, Nodo::DataFrame, nn::Int, bMVA::Int)

    # Generador:    DataFrame de los generadores
    # Nodo:         DataFrame de los nodos
    # nn:           Número de nodos
    # bMVA          Potencia base

    # El Dataframe introducido como argumento "dGen" en "Generador" contiene los datos de los generadores sacado de su correspondiente archivo "datosGeneradores.csv"
    # r = sparsevec(I, V, n) se crea la lista "r" cuyos índices es el vector "I" y los valores es el vector "V", 
    # cuyo tamaño total es de "n" elementos. Es decir, r[I[k]] = V[k] para k <= n
    # P_Cost es un sparsevec de "nn" elementos que recoge como 
        # Ínidices: nodo en el que están los generadores "Generador.bus"
        # Valores: coste de los respectivos generadores "Generador.P_COSTE"
    # Esto significa que la lista vacía de "nn" elementos se va llenando con los valores del coste en las posiciones del bus correspondiente
    # Por ejemplo: Si hay un generador en el bus 3 que cuesta 10€/MWh, la lista para los elementos 1 y 2 sigen vacíos y el elemento 3 se le asigna un 10
    P_Cost0 = SparseArrays.sparsevec(Generador.bus, Generador.c0, nn)
    P_Cost1 = SparseArrays.sparsevec(Generador.bus, Generador.c1, nn)
    P_Cost2 = SparseArrays.sparsevec(Generador.bus, Generador.c2, nn)

    # P_Gen_lb y P_Gen_ub son sparsevec de "nn" elementos de los limites inferior y superior, respectivamente, de la potencia activa de los gerneradores
        # Índices: nodo donde está el generador "Generador.bus"
        # Valores: límite inferior "Generador.Pmin" o superior "Generador.Pmax" del generador
    P_Gen_lb = SparseArrays.sparsevec(Generador.bus, Generador.Pmin, nn)
    P_Gen_ub = SparseArrays.sparsevec(Generador.bus, Generador.Pmax, nn)
    # Q_Gen_lb y Q_Gen_ub son sparsevec de "nn" elementos de los limites inferior y superior, respectivamente, de la potencia reactiva de los gerneradores
        # Índices: nodo donde está el generador "Generador.bus"
        # Valores: límite inferior "Generador.Qmin" o superior "Generador.Qmax" del generador
    Q_Gen_lb = SparseArrays.sparsevec(Generador.bus, Generador.Qmin, nn)
    Q_Gen_ub = SparseArrays.sparsevec(Generador.bus, Generador.Qmax, nn)

    # El Dataframe introducido como argumento "dNodos" en "Nodo" contiene los datos de la demanda sacado de su correspondiente archivo "datosNodos.csv"
    # P_Demand es un sparsevec de "nn" elementos donde se recoge como 
        # Índices: nodos donde se localiza la demanda "Nodo.bus_i"
        # Valores: demanda de potencia activa en los respectivos nodos "Nodo.P_DEMANDA"
    P_Demand = SparseArrays.sparsevec(Nodo.bus_i, Nodo.Pd, nn)
    # Q_Demand es un sparsevec de "nn" elementos donde se recoge como 
        # Índices: nodos donde está la demanda "Nodo.bus_i"
        # Valores: demanda de potencia reactiva en los respectivos nodos "Nodo.Q_DEMANDA"
    Q_Demand = SparseArrays.sparsevec(Nodo.bus_i, Nodo.Qd, nn)
    # Sumando ambos sparsevec se optiene la potencia aparente S = P + jQ
    S_Demand = P_Demand + im * Q_Demand

    # V_Nodo_lb y V_Nodo_ub son sparsevec de "nn" elementos de los limites inferior y superior, respectivamente, del voltaje en los nodos en valores pu
        # Índices: nodo
        # Valores: límite inferior "Nodo.Vmin" o superior "Nodo.Vmax" del generador
    V_Nodo_lb = SparseArrays.sparsevec(Nodo.bus_i, Nodo.Vmin, nn)
    V_Nodo_ub = SparseArrays.sparsevec(Nodo.bus_i, Nodo.Vmax, nn)
    V_baseNodo = SparseArrays.sparsevec(Nodo.bus_i, Nodo.baseKV, nn)

    # Conductancia y susceptancia shunt en los nodos
    Conduc_Sh = SparseArrays.sparsevec(Nodo.bus_i, Nodo.Gs, nn)
    Suscep_Sh = SparseArrays.sparsevec(Nodo.bus_i, Nodo.Bs, nn)

    # En los datos de los generadores se tiene en cuenta generadores que no están activos con status = 0
    # Por lo que se crea un sparsevec que contenga estos valores para considerar generadores apagados
    Gen_Status = SparseArrays.sparsevec(Generador.bus, Generador.status, nn)

    # Se devuelve como resultado de la función todos los SparseArrays generados
    return P_Cost0, P_Cost1, P_Cost2, P_Gen_lb, P_Gen_ub, Q_Gen_lb, Q_Gen_ub, S_Demand, V_Nodo_lb, V_Nodo_ub, V_baseNodo, Conduc_Sh, Suscep_Sh, Gen_Status

end