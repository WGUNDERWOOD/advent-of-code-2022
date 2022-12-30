println("Day 22")

# part 1

Point2 = Tuple{Int, Int}
Path = Vector{Union{Int, Char}}
Flat = Matrix{Char}


mutable struct FlatState
    loc::Point2
    dir::Char
    pos::Int
end


function parse_flat(filepath::String)

    file = readlines(filepath)
    m = length(file) - 2
    n = maximum(length(file[i]) for i in 1:m)
    flat = Flat(undef, m, n)

    for i in 1:m
        l = file[i]
        for j in 1:n
            if j <= length(l)
                flat[i, j] = l[j]
            else
                flat[i, j] = ' '
            end
        end
    end

    return flat
end


function parse_path(filepath::String)

    file = readlines(filepath)
    type = "Int"
    cur = ""
    path = Path()

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

    return path
end


function get_initial_state(flat::Flat)

    i = 1
    j = findfirst(x -> x != ' ', flat[i, :])
    state = FlatState((i, j), 'R', 1)

    return state
end


function move_flat(pos::Point2, dir::Char, flat::Flat)

    (m, n) = size(flat)
    (i, j) = pos
    (new_i, new_j) = pos

    if dir == 'R'
        if (j <= n-1) && (flat[i, j+1] == '.')
            new_j = j+1
        elseif ((j <= n-1) && (flat[i, j+1] == ' ')) || (j == n)
            wrap = findfirst(x -> x != ' ', flat[i, :])
            flat[i, wrap] == '.' ? new_j = wrap : nothing
        end

    elseif dir == 'L'
        if (j >= 2) && (flat[i, j-1] == '.')
            new_j = j-1
        elseif ((j >= 2) && (flat[i, j-1] == ' ')) || (j == 1)
            wrap = findlast(x -> x != ' ', flat[i, :])
            flat[i, wrap] == '.' ? new_j = wrap : nothing
        end

    elseif dir == 'D'
        if (i <= m-1) && (flat[i+1, j] == '.')
            new_i = i+1
        elseif ((i <= m-1) && (flat[i+1, j] == ' ')) || (i == m)
            wrap = findfirst(x -> x != ' ', flat[:, j])
            flat[wrap, j] == '.' ? new_i = wrap : nothing
        end

    elseif dir == 'U'
        if (i >= 2) && (flat[i-1, j] == '.')
            new_i = i-1
        elseif ((i >= 2) && (flat[i-1, j] == ' ')) || (i == 1)
            wrap = findlast(x -> x != ' ', flat[:, j])
            flat[wrap, j] == '.' ? new_i = wrap : nothing
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


function iterate_flat!(state::FlatState, flat::Flat, path::Path)

    instruction = path[state.pos]

    if isa(instruction, Char)
        state.dir = turn(instruction, state.dir)
    else
        for _ in 1:instruction
            state.loc = move_flat(state.loc, state.dir, flat)
        end
    end

    state.pos += 1
    return nothing
end


function password_flat(state::FlatState)
    state.dir == 'R' ? facing = 0 : nothing
    state.dir == 'D' ? facing = 1 : nothing
    state.dir == 'L' ? facing = 2 : nothing
    state.dir == 'U' ? facing = 3 : nothing
    return 1000 * state.loc[1] + 4 * state.loc[2] + facing
end


# part 2

Point3 = Tuple{Int, Int, Int}
Orientation = Tuple{Point3, Point3, Point3, Point3}

mutable struct CubeState
    id::Int
    loc::Point2
    dir::Char
    pos::Int
end


mutable struct Face
    id::Int
    board::Matrix{Char}
    orientation::Orientation
end

Cube = Dict{Int, Face}
Net = Matrix{Bool}


function parse_net(filepath::String)

    flat = parse_flat(filepath)
    (m, n) = size(flat)
    side_len = minimum(sum(flat[i,:] .!= ' ') for i in 1:m)
    (m_net, n_net) = (div(m, side_len), div(n, side_len))
    net = Net(undef, m_net, n_net)

    for r in 1:m_net, s in 1:n_net
        (i, j) = ((r-1) * side_len + 1, (s-1) * side_len + 1)
        if flat[i, j] != ' '
            net[r, s] = true
        else
            net[r, s] = false
        end
    end

    return net
end


function get_all_orientations(net::Net)

    (m_net, n_net) = size(net)
    all_orientations = Matrix{Union{Orientation, Nothing}}(nothing, m_net, n_net)

    # orientation of first face
    first_orientation = ((-1,1,1), (1,1,1), (-1,-1,1), (1,-1,1))
    all_orientations[1, findfirst(net[1, :])] = first_orientation

    # orientation of other faces
    for rep in 1:6
        for r in 1:m_net, s in 1:n_net
            if net[r,s] && !isnothing(all_orientations[r,s])

                if (r < m_net) && net[r+1, s] && isnothing(all_orientations[r+1, s])
                    all_orientations[r+1, s] = rotate.(all_orientations[r,s], 'D')
                end

                if (r > 1) && net[r-1, s] && isnothing(all_orientations[r-1, s])
                    all_orientations[r-1, s] = rotate.(all_orientations[r,s], 'U')
                end

                if (s < n_net) && net[r, s+1] && isnothing(all_orientations[r, s+1])
                    all_orientations[r, s+1] = rotate.(all_orientations[r,s], 'R')
                end

                if (s > 1) && net[r, s-1] && isnothing(all_orientations[r, s-1])
                    all_orientations[r, s-1] = rotate.(all_orientations[r,s], 'L')
                end

            end
        end
    end

    return all_orientations
end


function rotate(point::Point3, dir::Char)

    if dir == 'D'
        A = [1 0 0; 0 0 -1; 0 1 0]
    elseif dir == 'U'
        A = [1 0 0; 0 0 1; 0 -1 0]
    elseif dir == 'R'
        A = [0 0 1; 0 1 0; -1 0 0]
    elseif dir == 'L'
        A = [0 0 -1; 0 1 0; 1 0 0]
    end

    return Tuple(A * [i for i in point])
end


function parse_cube(filepath::String)

    net = parse_net(filepath)
    all_orientations = get_all_orientations(net)
    flat = parse_flat(filepath)
    (m, n) = size(flat)
    side_len = minimum(sum(flat[i,:] .!= ' ') for i in 1:m)
    (m_net, n_net) = (div(m, side_len), div(n, side_len))
    id = 1
    cube = Cube()

    for r in 1:m_net, s in 1:n_net
        if net[r, s]
            (i, j) = ((r-1) * side_len + 1, (s-1) * side_len + 1)
            board = flat[i:i+side_len-1, j:j+side_len-1]
            orientation = all_orientations[r, s]
            face = Face(id, board, orientation)
            cube[id] = face
            id += 1
        end
    end

    return cube
end


function get_initial_state(cube::Cube)

    id = 1
    i = 1
    j = findfirst(x -> x != ' ', cube[id].board[i, :])
    loc = (i, j)
    state = CubeState(id, (i, j), 'R', 1)
    return state
end





filepath = "day22test.txt"
#filepath = "day22.txt"

#=
# part 1

flat = parse_flat(filepath)
path = parse_path(filepath)
state = get_initial_state(flat)

for rep in 1:length(path)
    iterate_flat!(state, flat, path)
end

println(password_flat(state))
=#

# part 2

net = parse_net(filepath)
all_orientations = get_all_orientations(net)
cube = parse_cube(filepath)
path = parse_path(filepath)
state = get_initial_state(cube)
