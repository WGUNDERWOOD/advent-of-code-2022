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


function move_flat(loc::Point2, dir::Char, flat::Flat)

    (m, n) = size(flat)
    (i, j) = loc
    (new_i, new_j) = loc

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
    corner_loc::Point2
end

Cube = Dict{Int, Face}
Net = Matrix{Int}


function parse_net(filepath::String)

    flat = parse_flat(filepath)
    (m, n) = size(flat)
    side_len = minimum(sum(flat[i,:] .!= ' ') for i in 1:m)
    (m_net, n_net) = (div(m, side_len), div(n, side_len))
    net = Net(undef, m_net, n_net)
    id::Int = 1

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
    for rep in 1:5
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

    if dir == 'D'
        return face_coords[:, 1:3] * [0 -1 0 -1; 0 1 -1 0; 1 1 0 0]
    elseif dir == 'U'
        return face_coords[:, 1:3] * [1 0 1 0; -1 0 0 1; -1 -1 0 0]
    elseif dir == 'R'
        return face_coords[:, 1:3] * [0 0 -1 -1; 1 0 1 0; 0 -1 1 0]
    elseif dir == 'L'
        return face_coords[:, 1:3] * [1 1 0 0; -1 0 -1 0; -1 0 0 1]
    end
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
            face = Face(id, board, face_coords, (i,j))
            cube[id] = face
        end
    end

    return cube
end


function get_initial_state(cube::Cube)

    id::Int = 1
    i::Int = 1
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
    face_coords = face.face_coords
    faces = values(cube)
    dir = state.dir

    # get edge coords
    dir == 'U' ? edge_coords = face_coords[:,[1,2]] : nothing
    dir == 'R' ? edge_coords = face_coords[:,[2,4]] : nothing
    dir == 'D' ? edge_coords = face_coords[:,[3,4]] : nothing
    dir == 'L' ? edge_coords = face_coords[:,[1,3]] : nothing

    # find new face
    new_face = [f for f in faces if iscolsubset(edge_coords, f.face_coords) && f != face][]

    # find edge on new face
    edge_coords == new_face.face_coords[:, [1,2]] ? new_edge = 'U' : nothing
    edge_coords == new_face.face_coords[:, [2,1]] ? new_edge = 'U' : nothing
    edge_coords == new_face.face_coords[:, [2,4]] ? new_edge = 'R' : nothing
    edge_coords == new_face.face_coords[:, [4,2]] ? new_edge = 'R' : nothing
    edge_coords == new_face.face_coords[:, [3,4]] ? new_edge = 'D' : nothing
    edge_coords == new_face.face_coords[:, [4,3]] ? new_edge = 'D' : nothing
    edge_coords == new_face.face_coords[:, [1,3]] ? new_edge = 'L' : nothing
    edge_coords == new_face.face_coords[:, [3,1]] ? new_edge = 'L' : nothing

    # get loc on new face
    side_len = size(face.board, 1)
    (i, j) = state.loc

    if dir == 'R'
        new_edge == 'L' ? new_loc = (i, 1) : nothing
        new_edge == 'R' ? new_loc = (side_len - i + 1, side_len) : nothing
        new_edge == 'D' ? new_loc = (side_len, i) : nothing
        new_edge == 'U' ? new_loc = (1, side_len - i + 1) : nothing
    elseif dir == 'L'
        new_edge == 'L' ? new_loc = (side_len - i + 1, 1) : nothing
        new_edge == 'R' ? new_loc = (i, side_len) : nothing
        new_edge == 'D' ? new_loc = (side_len, side_len - i + 1) : nothing
        new_edge == 'U' ? new_loc = (1, i) : nothing
    elseif dir == 'D'
        new_edge == 'L' ? new_loc = (side_len - j + 1, 1) : nothing
        new_edge == 'R' ? new_loc = (j, side_len) : nothing
        new_edge == 'D' ? new_loc = (side_len, side_len - j + 1) : nothing
        new_edge == 'U' ? new_loc = (1, j) : nothing
    elseif dir == 'U'
        new_edge == 'L' ? new_loc = (j, 1) : nothing
        new_edge == 'R' ? new_loc = (side_len - j + 1, side_len) : nothing
        new_edge == 'D' ? new_loc = (side_len, j) : nothing
        new_edge == 'U' ? new_loc = (1, side_len - j + 1) : nothing
    end

    # get new direction
    new_edge == 'L' ? new_dir = 'R' : nothing
    new_edge == 'R' ? new_dir = 'L' : nothing
    new_edge == 'U' ? new_dir = 'D' : nothing
    new_edge == 'D' ? new_dir = 'U' : nothing

    # check not hitting a wall on the next face
    if new_face.board[new_loc[1], new_loc[2]] == '.'
        return (new_face.id, new_loc, new_dir)
    else
        return (face.id, state.loc, state.dir)
    end
end


function move_cube(state::CubeState, cube::Cube)

    face = cube[state.id]
    board = face.board
    side_len = size(board, 1)
    dir = state.dir
    (i, j) = state.loc
    new_id = state.id
    new_loc = state.loc
    new_dir = state.dir

    if dir == 'R'
        (j < side_len) && (board[i, j+1] == '.') ? new_loc = (i, j+1) : nothing
        j == side_len ? (new_id, new_loc, new_dir) = move_over_edge(state, cube) : nothing

    elseif dir == 'L'
        (j > 1) && (board[i, j-1] == '.') ? new_loc = (i, j-1) : nothing
        j == 1 ? (new_id, new_loc, new_dir) = move_over_edge(state, cube) : nothing

    elseif dir == 'D'
        (i < side_len) && (board[i+1, j] == '.') ? new_loc = (i+1, j) : nothing
        i == side_len ? (new_id, new_loc, new_dir) = move_over_edge(state, cube) : nothing

    elseif dir == 'U'
        (i > 1) && (board[i-1, j] == '.') ? new_loc = (i-1, j) : nothing
        i == 1 ? (new_id, new_loc, new_dir) = move_over_edge(state, cube) : nothing
    end

    return (new_id, new_loc, new_dir)
end


function iterate_cube!(state::CubeState, cube::Cube, path::Path)

    instruction = path[state.pos]

    if isa(instruction, Char)
        state.dir = turn(instruction, state.dir)
    else
        for _ in 1:instruction
            (state.id, state.loc, state.dir) = move_cube(state, cube)
        end
    end

    state.pos += 1
    return nothing
end


function password_cube(state::CubeState, cube::Cube)

    face = cube[state.id]
    corner_loc = face.corner_loc
    flat_loc = corner_loc .+ state.loc .- 1

    state.dir == 'R' ? facing = 0 : nothing
    state.dir == 'D' ? facing = 1 : nothing
    state.dir == 'L' ? facing = 2 : nothing
    state.dir == 'U' ? facing = 3 : nothing

    return 1000 * flat_loc[1] + 4 * flat_loc[2] + facing
end


# part 1

filepath = "day22.txt"
flat = parse_flat(filepath)
path = parse_path(filepath)
state = get_initial_state(flat)

for rep in 1:length(path)
    iterate_flat!(state, flat, path)
end

println("Part 1: ", password_flat(state))


# part 2

cube = parse_cube(filepath)
path = parse_path(filepath)
state = get_initial_state(cube)

for rep in 1:length(path)
    iterate_cube!(state, cube, path)
end

println("Part 2: ", password_cube(state, cube))
println()
