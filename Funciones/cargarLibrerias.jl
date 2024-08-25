# Librería básica para el problema de optimización
using JuMP

# Librerias de Optimizadores
using Gurobi            # LP_OPF
using HiGHS             # LP_OPF
using Ipopt             # AC_OPF - local
using AmplNLWriter      # AC_OPF - global
using Couenne_jll       # Librería adicional necesaria para AmplNLWriter

# Otras Librerias
using LinearAlgebra     # Operaciones lineales algebraicas
using SparseArrays      # Eficiencia en el código relacionadas a las matrices con muchos ceros
using DataFrames        # Relacionado con las tablas
using PrettyTables      # Estética para imprimir DataFrames en el terminal
using CSV               # Gestión de CSV

using PowerModels       # Paquete creada para resolver OPF directamente del archivo .m
using PowerPlots        # Mostrar en un gráfica el sistema