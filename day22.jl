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

mutable struct CubeState
    id::Int
    loc::Point2
    dir::Char
    pos::Int
end


mutable struct Face
    id::Int
    board::Matrix{Char}
    face_coords::Matrix{Int}
end

Cube = Dict{Int, Face}
Net = Matrix{Int}


function parse_net(filepath::String)

    flat = parse_flat(filepath)
    (m, n) = size(flat)
    side_len = minimum(sum(flat[i,:] .!= ' ') for i in 1:m)
    (m_net, n_net) = (div(m, side_len), div(n, side_len))
    net = Net(undef, m_net, n_net)
    id = 1

    for r in 1:m_net, s in 1:n_net
        (i, j) = ((r-1) * side_len + 1, (s-1) * side_len + 1)
        if flat[i, j] != ' '
            net[r, s] = id
            id += 1
        else
            net[r, s] = 0
        end
    end

    return net
end


function get_all_face_coords(net::Net)

    (m_net, n_net) = size(net)
    all_face_coords = Matrix{Union{Matrix{Int}, Nothing}}(nothing, m_net, n_net)

    # face_coords of first face
    first_face_coords = [-1 1 -1 1; 1 1 -1 -1; 1 1 1 1]
    all_face_coords[1, findfirst(net[1, :] .> 0)] = first_face_coords

    # face_coords of other faces
    for rep in 1:6
        for r in 1:m_net, s in 1:n_net
            if (net[r,s] > 0) && !isnothing(all_face_coords[r,s])

                if (r < m_net) && (net[r+1, s] > 0) && isnothing(all_face_coords[r+1, s])
                    all_face_coords[r+1, s] = rotate(all_face_coords[r,s], 'D')
                end

                if (r > 1) && (net[r-1, s] > 0) && isnothing(all_face_coords[r-1, s])
                    all_face_coords[r-1, s] = rotate(all_face_coords[r,s], 'U')
                end

                if (s < n_net) && (net[r, s+1] > 0) && isnothing(all_face_coords[r, s+1])
                    all_face_coords[r, s+1] = rotate(all_face_coords[r,s], 'R')
                end

                if (s > 1) && (net[r, s-1] > 0) && isnothing(all_face_coords[r, s-1])
                    all_face_coords[r, s-1] = rotate(all_face_coords[r,s], 'L')
                end

            end
        end
    end

    return all_face_coords
end


function rotate(face_coords::Matrix{Int}, dir::Char)

    first_face_coords = [-1 1 -1 1; 1 1 -1 -1; 1 1 1 1]
    A_face = face_coords[:,1:3] * inv(first_face_coords[:,1:3])

    if dir == 'D'
        A = [1 0 0; 0 0 -1; 0 1 0]
    elseif dir == 'U'
        A = [1 0 0; 0 0 1; 0 -1 0]
    elseif dir == 'R'
        A = [0 0 1; 0 1 0; -1 0 0]
    elseif dir == 'L'
        A = [0 0 -1; 0 1 0; 1 0 0]
    end

    return A_face * A * first_face_coords
end


function parse_cube(filepath::String)

    net = parse_net(filepath)
    all_face_coords = get_all_face_coords(net)
    flat = parse_flat(filepath)
    (m, n) = size(flat)
    side_len = minimum(sum(flat[i,:] .!= ' ') for i in 1:m)
    (m_net, n_net) = (div(m, side_len), div(n, side_len))
    cube = Cube()

    for r in 1:m_net, s in 1:n_net
        if net[r, s] > 0
            (i, j) = ((r-1) * side_len + 1, (s-1) * side_len + 1)
            id = net[r, s]
            board = flat[i:i+side_len-1, j:j+side_len-1]
            face_coords = all_face_coords[r, s]
            face = Face(id, board, face_coords)
            cube[id] = face
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


function iscolsubset(A1::Matrix{Int}, A2::Matrix{Int})

    n_cols = size(A1, 2)
    good_cols = [false for _ in 1:n_cols]

    for i in 1:n_cols
        col = A1[:,i]
        for j in 1:size(A2, 2)
            if col == A2[:,j]
                good_cols[i] = true
            end
        end
    end

    return all(good_cols)
end


function move_over_edge(state::CubeState, cube::Cube)

    face = cube[state.id]

    # get edge coords
    state.dir == 'U' ? edge_coords = face.face_coords[:,[1,2]] : nothing
    state.dir == 'R' ? edge_coords = face.face_coords[:,[2,4]] : nothing
    state.dir == 'D' ? edge_coords = face.face_coords[:,[3,4]] : nothing
    state.dir == 'L' ? edge_coords = face.face_coords[:,[1,3]] : nothing

    # find new face
    new_face = [f for f in values(cube) if iscolsubset(edge_coords, f.face_coords) && f != face][]


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
all_face_coords = get_all_face_coords(net)
cube = parse_cube(filepath)
path = parse_path(filepath)
state = get_initial_state(cube)
move_over_edge(state, cube)
