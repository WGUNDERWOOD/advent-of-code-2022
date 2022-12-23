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
            push!(tunnels, Tunnel(id, t, 1))
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


function shortest_path_lengths(source::String, cave::Cave)

    visited = [false for valve in cave.valves]
    lens = [valve.id == source ? 0 : Inf for valve in cave.valves]
    terminated = false
    n = length(cave.valves)
    m = length(cave.tunnels)
    lookup = Dict{String, Int}()
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
        terminated = length(unvisited_lens) == 0

    end

    return [lens[lookup[v.id]] for v in cave.valves]
end


function complete(cave::Cave)

    new_cave = deepcopy(cave)

    for valve1 in cave.valves
        lens = shortest_path_lengths(valve1.id, cave)
        for i in 1:length(cave.valves)
            valve2 = cave.valves[i]
            len = lens[i]
            if valve1 != valve2
                tunnel = Tunnel(valve1.id, valve2.id, len)
                push!(new_cave.tunnels, tunnel)
            end
        end
    end

    return new_cave
end


function remove_duplicate_tunnels(cave::Cave)

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

    new_cave = deepcopy(cave)
    new_cave.tunnels = collect(values(tunnels_dict))
    new_cave.tunnels = sort(new_cave.tunnels, by = (x -> x.source * x.dest))
    return new_cave
end


function remove_zero_valves(cave::Cave)

    zero_ids = [v.id for v in cave.valves if v.flow == 0 && v.id != "AA"]
    new_valves = [v for v in cave.valves if !(v.id in zero_ids)]
    new_tunnels = [t for t in cave.tunnels if !(t.source in zero_ids)]
    new_tunnels = [t for t in new_tunnels if !(t.dest in zero_ids)]

    new_cave = deepcopy(cave)
    new_cave.valves = new_valves
    new_cave.tunnels = new_tunnels
    return new_cave
end


function simplify(cave::Cave)
    println("Completing tunnels...")
    new_cave = complete(cave)
    println("Removing duplicate tunnels...")
    new_cave = remove_duplicate_tunnels(new_cave)
    println("Removing zero flow valves...")
    new_cave = remove_zero_valves(new_cave)
    return new_cave
end


function move(position::String, cave::Cave)

    new_cave = deepcopy(cave)

    if position != cave.position
        tunnel = [t for t in cave.tunnels if t.source == cave.position && t.dest == position][1]
        new_cave.time += tunnel.len
        new_cave.pressure += sum([v.flow for v in cave.valves if v.open]) * tunnel.len
        new_cave.position = position
    end

    return new_cave
end


function open(cave::Cave)

    new_cave = deepcopy(cave)
    n = length(cave.valves)
    i = [i for i in 1:n if cave.valves[i].id == cave.position][1]
    if !new_cave.valves[i].open
        new_cave.valves[i].open = true
        new_cave.time += 1
        new_cave.pressure += sum([v.flow for v in cave.valves if v.open])
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


function total_pressure(limit::Int, cave::Cave)

    flow = sum([v.flow for v in cave.valves if v.open])
    return cave.pressure + (limit - cave.time) * flow
end


function remove_dominated(caves::Vector{Cave})

    new_caves = Cave[]

    # TODO this is O(n^2). Check on the fly?
    for cave in caves
        if !any([better(c, cave) for c in new_caves])
            push!(new_caves, cave)
        end
    end

    return new_caves
end






#cave = parse_cave("day16test.txt")
cave = parse_cave("day16.txt")
cave = simplify(cave)
limit = 30
terminated = false
best_pressure = -Inf

checking = Cave[cave]
checked = Cave[]

function runall()

    for rep in 1:3
    #while !terminated

        new_caves = Cave[]

        for cave in checking

            counter = 0

            for position in [v.id for v in cave.valves if (v.id != cave.position) && !v.open]

                counter +=1
                new_cave = move(position, cave)
                new_cave = open(new_cave)

                if new_cave.time <= limit
                    if !any([better(c, new_cave) for c in [checking; checked]])
                        push!(new_caves, new_cave)
                    end
                end
            end
        end

        append!(checked, checking)
        global checked = remove_dominated(checked)

        global checking = new_caves
        global checking = remove_dominated(checking)

        old_best_pressure = best_pressure
        global best_pressure = maximum(total_pressure.(limit, checked))
        global terminated = (best_pressure == old_best_pressure)
        println("Total pressure: ", best_pressure)
        println("Checked: ", length(checked))
        println("Checking: ", length(checking))
    end
end













#=

#println(cave.pressure)
#println(cave.time)
#flow = sum([v.flow for v in cave.valves if v.open])
#println(flow)
#println(cave.pressure + (30 - cave.time) * flow)





ids = [valve.id for valve in cave.valves]
n_ids = length(ids)


caves = Dict(cave => cave.pressure)

for depth in 1:10

    println("depth: ", depth)

    for cave in collect(keys(caves))

        for position in [v.id for v in cave.valves if (v.id != cave.position) && !v.open]
            new_cave = move(position, cave)
            new_cave = open(new_cave)
            if !(new_cave in keys(caves))
                caves[new_cave] = new_cave.pressure
            end
        end
    end

    global caves = prune(limit, caves)
    println("num caves: ", length(caves))
    println("best total pressure: ", maximum(total_pressure.(limit, keys(caves))))
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
