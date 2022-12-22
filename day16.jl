mutable struct Valve
    id::String
    flow::Int
    open::Bool
end


mutable struct Tunnel
    source::String
    dest::String
    len::Int
end


mutable struct Cave
    valves::Vector{Valve}
    tunnels::Vector{Tunnel}
    time::Int
    pressure::Int
    position::String
end


function parse_cave(filepath::String)

    file = readlines(filepath)
    valves = Valve[]
    tunnels = Tunnel[]

    for l in file
        split_l = String.(split(l, [' ', ';', ',', '='], keepempty=false))
        id = split_l[2]
        flow = parse(Int, split_l[6])
        open = false
        push!(valves, Valve(id, flow, open))

        for t in split_l[11:end]
            source = id
            dest = t
            len = 1
            push!(tunnels, Tunnel(source, dest, len))
        end
    end

    time = 0
    pressure = 0
    position = "AA"

    sorted_valves = sort(valves, by = (x -> x.id))
    sorted_tunnels = sort(tunnels, by = (x -> x.source * x.dest))

    return Cave(sorted_valves, sorted_tunnels, time, pressure, position)
end


function show(cave::Cave)

    println("Time: ", cave.time)
    println("Pressure released: ", cave.pressure)
    println("Cuurent position: ", cave.position)

    println("Valves:")
    for valve in cave.valves
        print("   ", valve.id)
        print("   Flow: ", lpad(valve.flow, 2, " "))
        print("   Open: ", valve.open)
        println()
    end

    println("Tunnels:")
    for tunnel in cave.tunnels
        print("   ", tunnel.source, " -> ", tunnel.dest)
        print("   Length: ", tunnel.len)
        println()
    end
end


function shortest_path_length(source::String, dest::String, cave::Cave)

    visited = [false for valve in cave.valves]
    lens = [valve.id == source ? 0 : Inf for valve in cave.valves]
    terminated = false
    n = length(cave.valves)
    m = length(cave.tunnels)
    lookup = Dict()
    for i in 1:n
        lookup[cave.valves[i].id] = i
    end

    while !terminated

        min_unvis_len = minimum([lens[i] for i in 1:n if !visited[i]])
        current = [i for i in 1:n
                       if lens[i] == min_unvis_len && !visited[i]][1]
        neighbors = [lookup[cave.tunnels[i].dest] for i in 1:m
                         if cave.tunnels[i].source == cave.valves[current].id]

        for i in 1:length(neighbors)
            next = neighbors[i]
            len = [t.len for t in cave.tunnels
                       if lookup[t.source] == current && lookup[t.dest] == next][1]
            lens[next] = min(lens[current] + len, lens[next])
        end

        visited[current] = true
        unvisited_lens = [lens[i] for i in 1:n if !visited[i]]
        terminated = visited[lookup[dest]] || minimum(unvisited_lens) == Inf

    end

    return lens[lookup[dest]]
end


function complete!(cave::Cave)

    for valve1 in cave.valves
        for valve2 in cave.valves
            if valve1 != valve2
                len = shortest_path_length(valve1.id, valve2.id, cave)
                if len < Inf
                    tunnel = Tunnel(valve1.id, valve2.id, len)
                    push!(cave.tunnels, tunnel)
                end
            end
        end
    end

    return nothing
end


function remove_duplicate_tunnels!(cave::Cave)

    tunnels_dict = Dict()

    for tunnel in cave.tunnels

        source = tunnel.source
        dest = tunnel.dest
        id = (source, dest)

        if id in keys(tunnels_dict)
            tunnels_dict[id] = Tunnel(source, dest, min(tunnels_dict[id].len, tunnel.len))
        else
            tunnels_dict[id] = tunnel
        end
    end

    cave.tunnels = collect(values(tunnels_dict))
    cave.tunnels = sort(cave.tunnels, by = (x -> x.source * x.dest))
    return nothing
end


function remove_zero_valves!(cave::Cave)

    zero_ids = [v.id for v in cave.valves if v.flow == 0 && v.id != "AA"]
    new_valves = [v for v in cave.valves if !(v.id in zero_ids)]
    new_tunnels = [t for t in cave.tunnels if !(t.source in zero_ids)]
    new_tunnels = [t for t in new_tunnels if !(t.dest in zero_ids)]

    cave.valves = new_valves
    cave.tunnels = new_tunnels
    return nothing
end


function simplify!(cave::Cave)
    complete!(cave)
    remove_duplicate_tunnels!(cave)
    remove_zero_valves!(cave)
    return nothing
end


function move(position::String, cave::Cave)

    new_cave = deepcopy(cave)

    if position != cave.position
        tunnel = [t for t in cave.tunnels if t.source == cave.position && t.dest == position][1]
        new_cave.time += tunnel.len
        new_cave.pressure += sum([v.flow for v in cave.valves if v.open])
        new_cave.position = position
    end

    return new_cave
end


function open(cave::Cave)

    new_cave = deepcopy(cave)

    for i in 1:length(cave.valves)
        new_valve = cave.valves[i]
        if new_valve.id == cave.position
            if !new_valve.open
                new_cave.valves[i].open = true
                new_cave.time += 1
                new_cave.pressure += sum([v.flow for v in cave.valves if v.open])
            end
        end
    end

    return new_cave
end


function better(cave1::Cave, cave2::Cave)

    time = cave1.time <= cave2.time
    pressure = cave1.pressure >= cave2.pressure
    position = cave1.position == cave2.position

    n = length(cave1.valves)
    valves = all([cave1.valves[i].open >= cave2.valves[i].open for i in 1:n])

    return time && pressure && position && valves
end


function remove_dominated(caves::Dict{Cave, Int})

    new_caves = Dict{Cave, Int}()

    for cave in keys(caves)
        if !any([better(c, cave) for c in keys(new_caves)])
            push!(new_caves, cave => cave.pressure)
        end
    end

    return new_caves
end


function remove_time_limit(limit::Int, caves::Dict{Cave, Int})

    new_caves = Dict{Cave, Int}()

    for cave in keys(caves)
        if cave.time <= limit
            push!(new_caves, cave => cave.pressure)
        end
    end

    return new_caves
end


function prune(limit::Int, caves::Dict{Cave, Int})
    new_caves = remove_time_limit(limit, caves)
    new_caves = remove_dominated(new_caves)
    return new_caves
end


#=


#function show(valves::Dict{String, Valve})
    #for k in sort(collect(keys(valves)))
        #show(valves[k])
    #end
#end


#function show(path::Path)

    #print(path[1])

    #if length(path) > 1
        #for p in path[2:end]
            #print(" -> ")
            #print(p)
        #end
     #end

    #return nothing
#end


#function isvalid(path::Path, valves::Valve)

    #@assert path[1] == "AA"

    #if length(path) > 1
        #for i in 2:length(path)
            #source =
            #@assert path[i] in path
        #end
    #end

#end


#function value(path::Path, valves::Vector{Valve})
#end
=#




# prepare data
cave = parse_cave("day16test.txt")
#simplify!(cave)


cave = move("DD", cave)
cave = open(cave)
cave = move("CC", cave)
cave = move("BB", cave)
cave = open(cave)
cave = move("AA", cave)
cave = move("II", cave)
cave = move("JJ", cave)
cave = open(cave)
cave = move("II", cave)
cave = move("AA", cave)
cave = move("DD", cave)
cave = move("EE", cave)
cave = move("FF", cave)
cave = move("GG", cave)
cave = move("HH", cave)
cave = open(cave)
cave = move("GG", cave)
cave = move("FF", cave)
cave = move("EE", cave)
cave = open(cave)
cave = move("DD", cave)
cave = move("CC", cave)
cave = open(cave)

println(cave.pressure)
println(cave.time)
flow = sum([v.flow for v in cave.valves if v.open])
println(flow)

println(cave.pressure + (30 - cave.time) * flow)
















#=








ids = [valve.id for valve in cave.valves]
n_ids = length(ids)
limit = 30


caves = Dict(cave => cave.pressure)

for depth in 1:15

    println("depth: ", depth)

    for cave in collect(keys(caves))

        for position in [v.id for v in cave.valves if (v.id != cave.position) && !v.open]
            moved_cave = move(position, cave)
            if !(moved_cave in keys(caves))
                caves[moved_cave] = moved_cave.pressure
            end
        end

        opened_cave = open(cave)
        if !(opened_cave in keys(caves))
            caves[opened_cave] = opened_cave.pressure
        end

    end

    global caves = prune(limit, caves)
    println("num caves: ", length(caves))
    println("best pressure: ", maximum(values(caves)))
end

println()

display(maximum(values(caves)))
#display.(values(caves))
#println(counter)


#c1 = deepcopy(cave)

#println(length(caves))
#caves = prune(caves)
#println(length(caves))
#show.(keys(caves))


#for rep in 1:100000
    #position = rand([v.id for v in cave.valves])
    #println(position)
    #move!(position, cave)
    #show(cave)
#end

#println("done")
#open!(cave)
println()

=#
