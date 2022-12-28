println("Day 22")

Board = Matrix{Char}
Path = Vector{Union{Int, Char}}

mutable struct State
    i::Int
    j::Int
    dir::Char
    loc::Int
end


function parse_input(filepath::String)

    file = readlines(filepath)
    m = length(file) - 2
    n = maximum(length(file[i]) for i in 1:m)
    board = Board(undef, m, n)
    path = Path()

    for i in 1:m
        l = file[i]
        for j in 1:n
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


function move(i::Int, j::Int, dir::Char, board::Board)

    (m, n) = size(board)

    if dir == 'R'
        if j <= n-1
            if board[i, j] == '.'

        end
    end

end


function iterate(state::State, board::Board, path::Path)
end


(state, board, path) = parse_input("day22test.txt")

state = iterate(state, board, path)
