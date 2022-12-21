struct Valve
    id::String
    flow::Int
    to::Set{String}
end


Path = Vector{String}


function parse_valves(filepath::String)

    file = readlines(filepath)
    valves = Dict{String, Valve}()

    for l in file
        split_l = String.(split(l, [' ', ';', ',', '='], keepempty=false))
        id = split_l[2]
        flow = parse(Int, split_l[6])
        to = Set(split_l[11:end])
        valves[id] = Valve(id, flow, to)
    end

    return valves
end


function show(valve::Valve)
    println("ID:     ", valve.id)
    println("  Flow: ", valve.flow)
    print("  To:   ")

    for t in valve.to
        print(t, " ")
    end
    println()
end


function show(valves::Dict{String, Valve})
    for k in sort(collect(keys(valves)))
        show(valves[k])
    end
end


function show(path::Path)

    print(path[1])

    if length(path) > 1
        for p in path[2:end]
            print(" -> ")
            print(p)
        end
     end

    return nothing
end


#function isvalid(path::Path, valves::V)

    #@assert path[1] == "AA"

    #if length(path) > 1
        #for i in 2:length(path)
            #source =
            #@assert path[i] in path

#end


#function value(path::Path, valves::Vector{Valve})
#end


valves = parse_valves("day16test.txt")
show(valves)
path = [valve.id for valve in values(valves)]
show(path)
println()
