using DataStructures


struct State
    opens::Set{UInt8}
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
    opens = Set{UInt8}()
    tunnels = Matrix{UInt8}(undef, n, n)
    tunnels .= 0

    for i in 1:n
        l = file[i]
        split_l = String.(split(l, [' ', ';', ',', '='], keepempty=false))
        flow = parse(Int, split_l[6])
        open = false
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


function Base.show(state::State)

    println("Time: ", state.time)
    println("Pressure released: ", state.pressure)
    println("Current position: ", state.position)

    print("Open valves: ")
    for k in state.opens
        print(k, " ")
    end
    println()

    return nothing
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


function remove_zero_valves(valves::Vector{UInt8}, tunnels::Matrix{UInt8}, AA_position::UInt8)

    n = length(valves)
    non_zeros = [i for i in 1:n if valves[i] != 0 || i == AA_position]
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

    return (new_valves, new_tunnels)
end


function move(position::UInt8, valves::Vector{UInt8}, tunnels::Matrix{UInt8}, state::State)

    # TODO use remaining time/pressure instead?
    n = length(valves)

    if position == state.position
        time = state.time + 1
        pressure = state.pressure + sum([valves[i] for i in 1:n if i in state.opens])

    else
        len = tunnels[state.position, position]
        time = state.time + len + 1
        pressure = state.pressure + sum([valves[i] for i in 1:n if i in state.opens]) * (len + 1)
    end

    opens = copy(state.opens)
    push!(opens, position)

    return State(opens, time, pressure, position)
end


function total_pressure(limit::Int, valves::Vector{UInt8}, state::State)

    n = length(valves)
    total_flow = sum([valves[i] for i in 1:n if i in state.opens])
    return state.pressure + (limit - state.time) * total_flow
end



# load and process input
(valves, tunnels, state, AA_position) = parse_input("day16.txt")
#(valves, tunnels, state, AA_position) = parse_input("day16test.txt")
tunnels = complete(valves, tunnels)
(valves, tunnels) = remove_zero_valves(valves, tunnels, AA_position)

n = length(valves)
limit = 30
checking = Deque{State}()
push!(checking, state)
best_score = 0

rep = 0

#for rep in 1:10000
while !isempty(checking)

    global rep += 1

    old_state = popfirst!(checking)

    for position in [UInt8(i) for i in 1:n if !(i in old_state.opens)]
        new_state = move(position, valves, tunnels, old_state)

        if new_state.time <= limit
            push!(checking, new_state)
            new_score = total_pressure(limit, valves, new_state)
            if new_score > best_score
                global best_score = new_score
                show(new_state)
                println(best_score)
            end
        end
    end

    if rep % 1000 == 0
        #println(rep)
        #println(best_score)
        #println(length(checking))
        #println(maximum([sum(values(s.opens)) for s in checking]))
        #println()
    end
    #show.(checking)
    #show.(checked)
    #println()
end

#show.(checking)
#println(length(checking))
#println(maximum([total_pressure(limit, valves, state) for state in checked]))
println(best_score)










#=
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
=#
