println("Day 16")


struct State
    opens::Vector{Bool}
    time::UInt16
    pressure::UInt16
    position::UInt8
end


function parse_input(filepath::String)

    file = readlines(filepath)
    n = length(file)
    id_to_index = Dict{String, UInt8}()

    for i in 1:n
        l = file[i]
        split_l = String.(split(l, [' ', ';', ',', '='], keepempty=false))
        id = split_l[2]
        id_to_index[id] = i
    end

    valves = Vector{UInt8}(undef, n)
    opens = Vector{Bool}(undef, n)
    tunnels = Matrix{UInt8}(undef, n, n)
    tunnels .= 0

    for i in 1:n
        l = file[i]
        split_l = String.(split(l, [' ', ';', ',', '='], keepempty=false))
        flow = parse(Int, split_l[6])
        opens .= false
        valves[i] = flow

        for dest in split_l[11:end]
            tunnels[i, id_to_index[dest]] = 1
        end
    end

    time = 0
    pressure = 0
    AA_position = id_to_index["AA"]
    state = State(opens, time, pressure, AA_position)

    return (valves, tunnels, state, AA_position)
end


function shortest_path_lengths(source::UInt8, valves::Vector{UInt8}, tunnels::Matrix{UInt8})

    n = length(valves)
    visited = fill(false, n)
    lens = fill(Inf, n)
    lens[source] = 0
    terminated = false

    while !terminated

        min_unvis_len = minimum([lens[i] for i in 1:n if !visited[i]])
        current = findfirst(i -> (lens[i] == min_unvis_len && !visited[i]), 1:n)

        for v in 1:n
            if v != current
                len = tunnels[current, v]
                if len > 0
                    lens[v] = min(lens[current] + len, lens[v])
                end
            end
        end

        visited[current] = true
        terminated = all(visited)
    end

    return lens
end


function complete(valves::Vector{UInt8}, tunnels::Matrix{UInt8})

    n = length(valves)
    new_tunnels = Matrix{UInt8}(undef, n, n)

    for v1 in 1:n
        lens = shortest_path_lengths(UInt8(v1), valves, tunnels)
        for v2 in 1:n
            if v1 != v2
                new_tunnels[v1, v2] = lens[v2]
            else
                new_tunnels[v1, v2] = UInt8(0)
            end
        end
    end

    return new_tunnels
end


function remove_zero_valves(valves::Vector{UInt8}, tunnels::Matrix{UInt8}, state::State)

    n = length(valves)
    non_zeros = [i for i in 1:n if valves[i] != 0 || i == state.position]
    nnz = length(non_zeros)
    new_valves = Vector{UInt8}(undef, nnz)
    new_tunnels = Matrix{UInt8}(undef, nnz, nnz)

    for i in 1:nnz
        new_valves[i] = valves[non_zeros[i]]
    end

    for i1 in 1:nnz
        for i2 in 1:nnz
            new_tunnels[i1, i2] = tunnels[non_zeros[i1], non_zeros[i2]]
        end
    end

    new_opens = [state.opens[non_zeros[i]] for i in 1:nnz]
    new_position = [i for i in 1:nnz if non_zeros[i] == state.position][1]
    new_state = State(new_opens, state.time, state.pressure, new_position)

    return (new_valves, new_tunnels, new_state)
end


function move(position::UInt8, valves::Vector{UInt8}, tunnels::Matrix{UInt8},
              state::State, limit::Int)

    n = length(valves)

    if position == state.position
        time = state.time + 1

    else
        len = tunnels[state.position, position]
        time = state.time + len + 1
    end

    pressure = state.pressure + valves[position] * max(limit - time, 0)
    opens = copy(state.opens)
    opens[position] = true

    return State(opens, time, pressure, position)
end


function get_best_pressure(valves::Vector{UInt8}, tunnels::Matrix{UInt8},
                           state::State, limit::Int)

    n = length(valves)
    checking = State[]
    push!(checking, state)
    best_pressure::Int = 0

    while !isempty(checking)
        old_state = pop!(checking)
        for position in UInt8(1):UInt8(n)
            if !old_state.opens[position]
                new_state = move(position, valves, tunnels, old_state, limit)
                if new_state.time <= limit
                    push!(checking, new_state)
                    if new_state.pressure > best_pressure
                        best_pressure = new_state.pressure
                    end
                end
            end
        end
    end

    return best_pressure
end


struct Path
    valves::Vector{UInt8}
    pressure::Int
end


function get_good_paths(valves::Vector{UInt8}, tunnels::Matrix{UInt8},
                        state::State, limit::Int, good_pressure::Int)

    n = length(valves)
    checking = Tuple{State, Path}[]
    good_paths = Path[]
    path = Path([state.position], state.pressure)
    push!(checking, (state, path))

    while !isempty(checking)
        (old_state, old_path) = pop!(checking)
        for position in UInt8(1):UInt8(n)
            if !old_state.opens[position]
                new_state = move(position, valves, tunnels, old_state, limit)
                if new_state.time <= limit
                    new_path = Path([old_path.valves; position], new_state.pressure)
                    push!(checking, (new_state, new_path))
                end
                if new_state.pressure > good_pressure
                    new_path = Path([old_path.valves; position], new_state.pressure)
                    push!(good_paths, new_path)
                end
            end
        end
    end

    return good_paths
end


function get_best_disjoint_path_pressure(good_paths::Vector{Path})

    best_pressure::Int = 0
    npaths = length(good_paths)

    for i in 1:npaths
        for j in 1:npaths
            if i < j
                p1 = good_paths[i]
                p2 = good_paths[j]
                new_pressure = p1.pressure + p2.pressure
                if new_pressure > best_pressure
                    if isempty(intersect(p1.valves[2:end], p2.valves[2:end]))
                        best_pressure = new_pressure
                    end
                end
            end
        end
    end

    return best_pressure
end


# parse input
(valves, tunnels, state, AA_position) = parse_input("day16.txt")
tunnels = complete(valves, tunnels)
(valves, tunnels, state) = remove_zero_valves(valves, tunnels, state)

# part 1
limit = 30
best_pressure = get_best_pressure(valves, tunnels, state, limit)
println("Part 1: ", best_pressure)

# part 2
limit = 26
good_pressure = 1200
good_paths = get_good_paths(valves, tunnels, state, limit, good_pressure)
best_disjoint_pressure = get_best_disjoint_path_pressure(good_paths)
println("Part 2: ", best_disjoint_pressure)
println()
