using LinearAlgebra

### DATOS ###
# Impedancias de línea
Z12 = Complex(0.02, 0.06)
Z23 = Complex(0.06, 0.13)
Z13 = Complex(0.08, 0.17)

# Demanda
Sd2 = Complex(-0.7, -0.15) # Demanda de (70 + j15) MW
Sd3 = Complex(-0.6, -0.1)  # Demanda de (60 + j10) MW


### CÁLCULO DE LA MATRIZ ADMITANCIA ###
# Cálculo de las admitancias de línea
Y12 = 1 / Z12
Y23 = 1 / Z23
Y13 = 1 / Z13

# Matriz admitancia
Ybus = [
    Y12 + Y13   -Y12        -Y13;
    -Y12        Y12 + Y23   -Y23;
    -Y13        -Y23        Y13 + Y23
]


### ITERACIÓN DE NEWTON-RAPHSON ###
V1 = Complex(1.0, 0.0)  # Nodo 1 es el nodo "slack" (de referencia)
V2 = Complex(1.0, 0.0)  # Valor inicial de la tensión en el nodo 2
V3 = Complex(1.0, 0.0)  # Valor inicial de la tensión en el nodo 3

tolerancia = 10^-9 # Tolerancia que se quiere alcanzar en la iteracción
max_iter = 1000 # Número máximo de iteracciones

for _ in 1:max_iter
    # Calculamos las corrientes inyectadas como el conjugado del
    # cocientre entre la potencia aparente de la demanda y la tensión en el nodo
    I2 = conj(Sd2 / V2)
    I3 = conj(Sd3 / V3)

    # Calculamos las nuevas tensiones
    V2_new = (I2 - Ybus[2, 1] * V1 - Ybus[2, 3] * V3) / Ybus[2, 2]
    V3_new = (I3 - Ybus[3, 1] * V1 - Ybus[3, 2] * V2) / Ybus[3, 3]

    # Comprobamos la convergencia, si la diferencia entre el nuevo valor y el anterior
    # es inferior a la tolerancia buscada, el problema se termina
    if abs(V2_new - V2) < tolerancia && abs(V3_new - V3) < tolerancia
        V2, V3 = V2_new, V3_new
        break
    end

    # En caso contrario, guardamos los nuevos valores para la siguiente iteraccion
    global V2, V3 = V2_new, V3_new
end

# Cálculo de la potencia en el generador en el nodo 1
I1 = Ybus[1, 1] * V1 + Ybus[1, 2] * V2 + Ybus[1, 3] * V3
S1 = V1 * conj(I1)

# Cálculo del flujo de potencia en las líneas
S12 = V1 * conj(Ybus[1,2] * (V2 - V1))
S23 = V2 * conj(Ybus[2,3] * (V3 - V2))
S13 = V1 * conj(Ybus[1,3] * (V3 - V1))

# Se muestra los resultados en el terminal
println("V2  = ", round(V2, digits = 3), " = ", round(abs(V2), digits = 3), "/_", round(rad2deg(angle(V2)), digits = 3), " pu")
println("V3  = ", round(V3, digits = 3), " = ", round(abs(V3), digits = 3), "/_", round(rad2deg(angle(V3)), digits = 3), " pu")
println("Pg  = ", round(real(S1), digits = 3), " pu")
println("Qg  = ", round(imag(S1), digits = 3), " pu")
println("S12 = ", round(S12, digits = 3), " = ", round(abs(S12), digits = 3), " pu")
println("S23 = ", round(S23, digits = 3), " = ", round(abs(S23), digits = 3), " pu")
println("S13 = ", round(S13, digits = 3), " = ", round(abs(S13), digits = 3), " pu")