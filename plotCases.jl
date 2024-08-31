# Este archivo .jl sirve para crear una imagen gráfica (plots)
# de los casos que se estudia para ver gráficamente las congestiones
# en las líneas, la generación y la distribución de demanda.

# Este archivo se ha recogido de 
# https://wispo-pop.github.io/PowerPlots.jl/stable/examples/advanced%20examples/

# Paquetes utilizados
using JuMP          # Para problemas de OPF
using Ipopt         # Solver utilizado para obtener la solución
using PowerModels   # Librería para la resolución del OPF
using PowerPlots    # Paquete para mostrar gráficamente el sistema
using PGLib         # Librería de todos los casos

include("./Funciones/elegirOpcion.jl")
include("./Funciones/limpiarTerminal.jl")

# Librerrías extras para modificación del gráfico
using ColorSchemes  # Colores
using Setfield


limpiarTerminal()
# Casos de estudio
# Carga en el vector "caso" la lista de carpetas que hay en la carpeta de "Casos"
listaCasos = readdir("Casos")
# Se carga la lista y el nombre a la función de elegir opción
casoEst = elegirOpcion(listaCasos, "caso")

limpiarTerminal()

# Se elimina la parte inicial del caso "pglib_opf_" y se mantiene el resto
nombreCaso = casoEst[11:end]

# Se accede al caso con el paquete PGLib
caso = pglib(nombreCaso)

# Se resuelve el caso con PowerModels
result = solve_ac_opf(caso, Ipopt.Optimizer)

# Se actualiza los datos con los datos obtenidos de la optimización
update_data!(caso, result["solution"])

# Se crea un PowerPlots con los datos que se quiere mostrar y los colores
p = powerplot(caso,
    gen_data=:pg,
    gen_data_type=:quantitative,
    branch_data=:pt,
    branch_data_type=:quantitative,
    branch_color=["green", "yellow","red"], # Rango de colores de las líneas
    gen_color=["green", "yellow","red"], # Rango de colores de los generadores
    flow_arrow_size_range=[0, 4000],
    load_color="blue", # Color de la carga
    bus_color="purple", # Color de los nodos
    bus_size= 50 # Tamaño de los nodos
)

# Asignación del color del vector
p.layer[1]["layer"][2]["mark"]["color"]=:white
p.layer[1]["layer"][2]["mark"]["stroke"]=:black

# Asignación de los valores del color para las líneas
p.layer[1]["transform"] = Dict{String, Any}[
    Dict("calculate"=>"abs(datum.pt)/datum.rate_a*100", "as"=>"branch_Percent_Loading"),
    Dict("calculate"=>"abs(datum.pt)", "as"=>"BranchPower")
]
p.layer[1]["layer"][1]["encoding"]["color"]["field"]="branch_Percent_Loading"
p.layer[1]["layer"][1]["encoding"]["color"]["title"]="Carga de línea [%]"
p.layer[1]["layer"][1]["encoding"]["color"]["scale"]["domain"]=[0,100]

p.layer[2]["encoding"]["color"]["title"]="Líneas"

# Asignación del estilo de los nodos
p.layer[3]["encoding"]["color"]["title"]="Nodos"
p.layer[3]["mark"]["type"]=:point # :circle :square :point
p.layer[3]["mark"]["shape"]="triangle-down" # Solo se puede usar si type = :point
# "circle", "square", "cross", "diamond", "triangle-up",
# "triangle-down", "triangle-right", or "triangle-left"

# Asignación del tamaño y color de los generadores
p.layer[4]["transform"] = Dict{String, Any}[
    Dict("calculate"=>"datum.pg/(datum.pmax+1e-9)*100", "as"=>"gen_Percent_Loading"),
    Dict("calculate"=>"datum.pmax", "as"=>"GenPower")
]
p.layer[4]["encoding"]["color"]["field"]="gen_Percent_Loading"
p.layer[4]["encoding"]["color"]["scale"]["domain"]=[0,100]
p.layer[4]["encoding"]["color"]["title"]="Carga de generador [%]"
p.layer[4]["encoding"]["size"]=Dict(
    "field"=>"GenPower", "title"=>"Potencia máx gen [pu]",
    "type"=>"quantitative", "scale"=>Dict("range"=>[10,250]), # Rango de tamaño de los generadores
)
p.layer[4]["mark"]["type"]=:circle # :circle :square :point

# Asignación del tamaño y color de la demanda
p.layer[5]["encoding"]["size"]=Dict(
    "field"=>"pd", "title"=>"Demanda [pu]",
    "type"=>"quantitative",
    "scale"=>Dict("range"=>[10,250]) # Rango de tamaño de la demanda
)
p.layer[5]["encoding"]["color"]["title"]= "Demanda"
p.layer[5]["mark"]["type"]=:square # :circle :square :point

# Posición de la leyenda
p.layer[1]["layer"][1]["encoding"]["color"]["legend"]=Dict("orient"=>"bottom-right", "offset"=>-50)
p.layer[4]["encoding"]["color"]["legend"]=Dict("orient"=>"bottom-right")
p.layer[5]["encoding"]["color"]["legend"]=Dict("orient"=>"bottom-right")

@set! p.resolve.scale.size = :independent
@set! p.resolve.scale.color = :shared
@set! p.encoding.color=Dict("legend"=>Dict("orient"=>"bottom"))

# Llamada al plot para que se muestre
p