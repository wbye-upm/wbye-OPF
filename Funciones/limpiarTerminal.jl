# Esta función es para limpiar el terminal donde se esté ejecutando el código
function limpiarTerminal()

    # En caso de que el terminal sea de Windows
    if Sys.iswindows()
        Base.run(`cmd /c cls`)

    # En caso de otros terminales basados en Unix
    else
        Base.run(`clear`)
    end
    
end