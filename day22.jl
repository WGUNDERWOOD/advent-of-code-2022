#println("Day 22")

Board = Matrix{Char}
Path = Vector{Union{Int, Char}}

mutable struct State
    i::Int
    j::Int
    dir::Char
    loc::Int
end


function show(state::State, board::Board, path::Path)

    (m, n) = size(board)

    for i in 1:m
        for j in 1:n
            if (i, j) == (state.i, state.j)
                if state.dir == 'R'
                    print('>')
                elseif state.dir == 'L'
                    print('<')
                elseif state.dir == 'U'
                    print('^')
                elseif state.dir == 'D'
                    print('v')
                end
            else
                print(board[i,j])
            end
        end
        println()
    end
    println()
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

    i = 1
    j = findfirst(x -> x != ' ', board[i, :])

    state = State(i, j, 'R', 1)

    return (state, board, path)
end


function move(i::Int, j::Int, dir::Char, board::Board)

    (m, n) = size(board)
    new_i = i
    new_j = j

    if dir == 'R'
        if (j <= n-1) && (board[i, j+1] == '.')
            new_j = j+1
        elseif ((j <= n-1) && (board[i, j+1] == ' ')) || (j == n)
            wrap = findfirst(x -> x != ' ', board[i, :])
            board[i, wrap] == '.' ? new_j = wrap : nothing
        end

    elseif dir == 'L'
        if (j >= 2) && (board[i, j-1] == '.')
            new_j = j-1
        elseif ((j >= 2) && (board[i, j-1] == ' ')) || (j == 1)
            wrap = findlast(x -> x != ' ', board[i, :])
            board[i, wrap] == '.' ? new_j = wrap : nothing
        end

    elseif dir == 'D'
        if (i <= m-1) && (board[i+1, j] == '.')
            new_i = i+1
        elseif ((i <= m-1) && (board[i+1, j] == ' ')) || (i == m)
            wrap = findfirst(x -> x != ' ', board[:, j])
            board[wrap, j] == '.' ? new_i = wrap : nothing
        end

    elseif dir == 'U'
        if (i >= 2) && (board[i-1, j] == '.')
            new_i = i-1
        elseif ((i >= 2) && (board[i-1, j] == ' ')) || (i == 1)
            wrap = findlast(x -> x != ' ', board[:, j])
            board[wrap, j] == '.' ? new_i = wrap : nothing
        end
    end

    return (new_i, new_j)
end


function turn(instruction::Char, dir::Char)

    if instruction == 'L'
        dir == 'R' ? ans = 'U' : nothing
        dir == 'L' ? ans = 'D' : nothing
        dir == 'U' ? ans = 'L' : nothing
        dir == 'D' ? ans = 'R' : nothing
    elseif instruction == 'R'
        dir == 'R' ? ans = 'D' : nothing
        dir == 'L' ? ans = 'U' : nothing
        dir == 'U' ? ans = 'R' : nothing
        dir == 'D' ? ans = 'L' : nothing
    end

    return ans
end


function iterate!(state::State, board::Board, path::Path)

    instruction = path[state.loc]

    if isa(instruction, Char)
        state.dir = turn(instruction, state.dir)
    else
        for _ in 1:instruction
            (state.i, state.j) = move(state.i, state.j, state.dir, board)
        end
    end

    state.loc += 1
    return nothing
end


function password(state::State, board::Board)
    state.dir == 'R' ? facing = 0 : nothing
    state.dir == 'D' ? facing = 1 : nothing
    state.dir == 'L' ? facing = 2 : nothing
    state.dir == 'U' ? facing = 3 : nothing
    return 1000 * state.i + 4 * state.j + facing
end


#(state, board, path) = parse_input("day22test.txt")
(state, board, path) = parse_input("day22.txt")
#show(state, board, path)

for rep in 1:length(path)
    iterate!(state, board, path)
    #if isa(path[state.loc], Int)
        #println(state.dir)
        #println(path[state.loc])
        #println(state.i, ", ", state.j)
        #show(state, board, path)
        #println()
    #end
    #show(state, board, path)
    #sleep(0.4)
end

println(password(state, board))

# 3512 too low


println()
