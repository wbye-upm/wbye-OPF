# Se cargan todas las funciones creadas

include("./boot.jl")                    # Inicializador para cargar todas las funciones

include("./limpiarTerminal.jl")         # Limpieza del terminal
include("./elegirOpcion.jl")            # Elección y confirmación de la opción por parte del usuario
include("./extraerDatos.jl")            # Estrae los datos del caso seleccionado y los guarda en SparseArrays
include("./selectEstudio.jl")           # Elección del caso que se quiere estudiar
include("./gestorResultados.jl")        # Gestiona el resultado obtenido de la optimización

include("../OPF/LP_OPF/LP_OPF.jl")      # Función del Linear Programming - Optimal Power Flow
include("../OPF/AC_OPF/AC_OPF.jl")      # Función del Alternating Current - Optimal Power Flow