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


function move!(position::String, cave::Cave)

    if position != cave.position
        tunnel = [t for t in cave.tunnels if t.source == cave.position && t.dest == position][1]
        cave.time += tunnel.len
        cave.pressure += sum([v.flow for v in cave.valves if v.open])
        cave.position = position
    end
end


function open!(cave::Cave)

    for i in 1:length(cave.valves)
        valve = cave.valves[i]
        if valve.id == cave.position
            if !valve.open
                cave.valves[i].open = true
                cave.time += 1
            end
        end
    end
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


cave = parse_cave("day16test.txt")
simplify!(cave)
println("ready")

for rep in 1:200000
    position = rand([v.id for v in cave.valves])
    #println(position)
    move!(position, cave)
    #show(cave)
end

println("done")
#open!(cave)
println()
