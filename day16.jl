mutable struct Valve
    id::String
    flow::Int
end


mutable struct Tunnel
    source::String
    dest::String
    len::Int
end


mutable struct Cave
    valves::Dict{String, Valve}
    tunnels::Dict{Tuple{String, String}, Tunnel}
    time::Int
    pressure::Int
    position::String
end


function parse_cave(filepath::String)

    file = readlines(filepath)
    valves = Dict{String, Valve}()
    tunnels = Dict{Tuple{String, String}, Tunnel}()

    for l in file
        split_l = String.(split(l, [' ', ';', ',', '='], keepempty=false))
        id = split_l[2]
        flow = parse(Int, split_l[6])
        valves[id] = Valve(id, flow)

        for t in split_l[11:end]
            source = id
            dest = t
            len = 1
            tunnels[(source, dest)] = Tunnel(source, dest, len)
        end
    end

    time = 0
    pressure = 0
    position = "AA"

    return Cave(valves, tunnels, time, pressure, position)
end


function show(cave::Cave)

    sorted_valves = sort(collect(values(cave.valves)), by = (x -> x.id))

    println("Valves:")
    for valve in sorted_valves
        println("  ID: ", valve.id, "     Flow: ", valve.flow)
    end

    sorted_tunnels = sort(collect(values(cave.tunnels)), by = (x -> x.source * x.dest))

    println("Tunnels:")
    for tunnel in sorted_tunnels
        println("  ", tunnel.source, " -> ", tunnel.dest, "   Length: ", tunnel.len)
    end
end


function shortest_path(source::String, dest::String, cave::Cave)

    visited = Dict{String, Bool}()
    dists = Dict{String, Float64}()

    # initialize
    for k in keys(cave.valves)
        visited[k] = false
        dists[k] = Inf
    end

    dists[source] = 0.0
    current = source
    terminated = false

    #for rep in 1:3
    while !terminated

        unvisited_dists = [dists[k] for k in keys(cave.valves) if !visited[k]]
        min_unvisited_dist = minimum(unvisited_dists)
        current = [k for k in keys(cave.valves) if dists[k] == min_unvisited_dist
                       && !visited[k]][1]
        neighbors = [k[2] for k in keys(cave.tunnels) if k[1] == current]
        for next in neighbors
            dist = cave.tunnels[(current, next)].len
            dists[next] = min(dists[current] + dist, dists[next])
            #println(next)
        end

        visited[current] = true
        unvisited_dists = [dists[k] for k in keys(cave.valves) if !visited[k]]
        terminated = visited[dest] || minimum(unvisited_dists) == Inf

    end

    println()
    println(current)
    println()
    for k in keys(dists)
        println(k, ", ", dists[k], ", ", visited[k])
    end


end


#=
function simplify!(cave::Cave)

    no_flow = [valve for valve in values(cave.valves) if valve.flow == 0]

    for i in 1:length(no_flow)
        valve = no_flow[i]

        # add new tunnels
        for tunnel1 in values(cave.tunnels)
            for tunnel2 in values(cave.tunnels)
                if tunnel1.source != tunnel2.dest
                    if (tunnel1.dest == valve.id) && (tunnel2.source == valve.id)
                        new_source = tunnel1.source
                        new_dest = tunnel1.source
                        dist = tunnel1.dist + tunnel2.dist
                        new_tunnel = Tunnel(tunnel1.source, tunnel2.dest, dist)
                        cave.tunnels[(tunnel1.source, tunnel2.dest)],
                    end
                end
            end
        end

        # delete zero flow valves
        deleteat!(cave.valves, findall(v -> v == valve, cave.valves))
    end

    # remove duplicates
    dists = Dict()
    for tunnel in cave.tunnels
        if tunnel in keys(dists)
            dists[tunnel] = min(dists[tunnel], tunnel.dist)
        else
            dists[tunnel] = tunnel.dist
        end
    end
    cave.tunnels = collect(keys(dists))

    return nothing
end


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
show(cave)
shortest_path("AA", "EE", cave)
#simplify!(cave)
println()
