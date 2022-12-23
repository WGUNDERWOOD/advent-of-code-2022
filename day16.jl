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
    println("Cuurent position: ", state.position)

    println("Valves:")
    for k in keys(state.valves)
        print("   ", k)
        print("   Open: ", state.opens[k])
        println()
    end

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



#(valves, tunnels, state) = parse_state("day16.txt")
(valves, tunnels, state) = parse_state("day16test.txt")
#show(state)

tunnels = complete(valves, tunnels)
(valves, tunnels) = remove_zero_valves(valves, tunnels)
display(tunnels)
