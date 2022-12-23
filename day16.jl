using Combinatorics


mutable struct State
    opens::Dict{String, Bool}
    time::Int
    pressure::Int
    position::String
end


Valves = Dict{String, Int}
Tunnels = Dict{Tuple{String, String}, Int}


function parse_input(filepath::String)

    file = readlines(filepath)
    valves = Valves()
    opens = Dict{String, Bool}()
    tunnels = Tunnels()

    for l in file
        split_l = String.(split(l, [' ', ';', ',', '='], keepempty=false))
        id = split_l[2]
        flow = parse(Int, split_l[6])
        open = false
        valves[id] = flow
        opens[id] = open

        for dest in split_l[11:end]
            tunnels[id, dest] = 1
        end
    end

    time = 0
    pressure = 0
    position = "AA"
    state = State(opens, time, pressure, position)

    return (valves, tunnels, state)
end


function show(state::State)

    println("Time: ", state.time)
    println("Pressure released: ", state.pressure)
    println("Current position: ", state.position)

    print("Open valves: ")
    for k in keys(state.opens)
        if state.opens[k]
            print(k, " ")
        end
    end
    println()

    return nothing
end


function shortest_path_lengths(source::String, valves::Valves, tunnels::Tunnels)

    ks = keys(valves)
    visited = Dict{String, Bool}(ks .=> false)
    lens = Dict(ks .=> Inf)
    lens[source] = 0
    terminated = false

    while !terminated

        min_unvis_len = minimum([lens[k] for k in ks if !visited[k]])
        current = [k for k in ks if lens[k] == min_unvis_len && !visited[k]][begin]

        for (v1, v2) in keys(tunnels)
            if v1 == current
                len = tunnels[(v1, v2)]
                lens[v2] = min(lens[v1] + len, lens[v2])
            end
        end

        visited[current] = true
        terminated = all(values(visited))
    end

    return lens
end


function complete(valves::Valves, tunnels::Tunnels)

    ks = keys(valves)
    new_tunnels = Tunnels()

    for v1 in ks
        lens = shortest_path_lengths(v1, valves, tunnels)
        for v2 in ks
            if v1 != v2
                new_tunnels[(v1, v2)] = lens[v2]
            end
        end
    end

    return new_tunnels
end


function remove_zero_valves(valves::Valves, tunnels::Tunnels)

    ks = keys(valves)
    non_zeros = [k for k in ks if valves[k] != 0 || k == "AA"]
    new_valves = Valves()
    new_tunnels = Tunnels()

    for k in non_zeros
        new_valves[k] = valves[k]
    end

    for k1 in non_zeros
        for k2 in non_zeros
            if haskey(tunnels, (k1, k2))
                new_tunnels[(k1, k2)] = tunnels[(k1, k2)]
            end
        end
    end

    return (new_valves, new_tunnels)
end


function move(position, valves, tunnels, state)

    new_state = state
    len = tunnels[(state.position, position)]
    new_state.time += len + 1
    new_state.pressure += sum([valves[k] for k in ks if state.opens[k]]) * (len + 1)
    new_state.position = position
    new_state.opens[position] = true

    return new_state
end


function total_pressure(limit::Int, valves::Valves, state::State)

    total_flow = sum([valves[k] for k in keys(valves) if state.opens[k]])
    return state.pressure + (limit - state.time) * total_flow
end



# load and process input
(valves, tunnels, state) = parse_input("day16.txt")
#(valves, tunnels, state) = parse_input("day16test.txt")
tunnels = complete(valves, tunnels)
(valves, tunnels) = remove_zero_valves(valves, tunnels)
ks = keys(valves)
states = State[]
limit = 30
perms = permutations(collect(ks))

# TODO this iteration is too slow
# TODO need to abandon branches faster

for perm in perms

    println(perm)
    if perm[1] != "AA"

        new_state = deepcopy(state)

        for i in 1:length(perm)
            if new_state.time <= limit
                new_state = move(perm[i], valves, tunnels, new_state)
            end
        end

        if new_state.time <= limit
            push!(states, new_state)
        end
    end
end

#show.(states)
println(maximum([total_pressure(limit, valves, state) for state in states]))
println()
