println("Day 22")

mutable struct State
    i::Int
    j::Int
    dir::Char
    loc::Int
end


function parse_input(filepath::String)

    file = readlines(filepath)
    n = length(file) - 2
    m = maximum(length(file[i]) for i in 1:n)
    board = Matrix{Char}(undef, n, m)
    path = Union{Int, Char}[]

    for i in 1:n
        l = file[i]
        for j in 1:m
            if j <= length(l)
                board[i, j] = l[j]
            else
                board[i, j] = ' '
            end
        end
    end

    type = "Int"
    cur = ""

    for c in file[end]
        if (type == "Int") && (c in '0':'9')
            cur = parse(Int, string(cur) * c)
        elseif (type == "Int") && !(c in '0':'9')
            push!(path, cur)
            push!(path, c)
            type = "Char"
        elseif (type == "Char") && (c in '0':'9')
            cur = parse(Int, c)
            type = "Int"
        elseif (type == "Char") && !(c in '0':'9')
            push!(path, c)
        end
    end

    if type == "Int"
        push!(path, cur)
    end

    state = State(1, 1, 'R', 1)

    return (state, board, path)
end


(state, board, path) = parse_input("day22test.txt")
