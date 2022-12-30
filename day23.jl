println("Day 23")

mutable struct Elf
    id::Int
    loc::Tuple{Int, Int}
    dirs::Vector{Tuple{Int, Int}}
    prop_loc::Tuple{Int, Int}
end


function parse_input(filepath)

    file = readlines(filepath)
    (m, n) = (length(file), length(file[1]))
    dirs = [(-1,0), (1,0), (0,-1), (0,1)] # NSWE
    elves = Elf[]
    id = 1

    for i in eachindex(file)
        for j in eachindex(file[i])
            c = file[i][j]
            if c == '#'
                loc = (i, j)
                prop_loc = (0, 0)
                elf = Elf(id, loc, copy(dirs), prop_loc)
                push!(elves, elf)
                id += 1
            end
        end
    end

    return elves
end


function first_half!(elves::Vector{Elf})

    for elf in elves
        loc = elf.loc
        elf.prop_loc = loc
        nbors = [(i, j) for i in loc[1]-1:loc[1]+1 for j in loc[2]-1:loc[2]+1]

        if !any(e.loc in nbors for e in elves if e != elf)
            elf.prop_loc = elf.loc

        else
            for dir in reverse(elf.dirs)
                adj = [elf.loc .+ dir .+ a for a in [(0,0), reverse(dir), -1 .* reverse(dir)]]
                if !any(e.loc in adj for e in elves)
                    elf.prop_loc = elf.loc .+ dir
                end
            end
        end
    end
end


function second_half!(elves::Vector{Elf})

    for elf in elves
        if !any(e.prop_loc == elf.prop_loc for e in elves if e != elf)
            elf.loc = elf.prop_loc
        end

        dir = popfirst!(elf.dirs)
        push!(elf.dirs, dir)
    end
end


function get_bounding_rectangle(elves::Vector{Elf})

    locs = [e.loc for e in elves]
    lo_i = minimum(loc[1] for loc in locs)
    hi_i = maximum(loc[1] for loc in locs)
    lo_j = minimum(loc[2] for loc in locs)
    hi_j = maximum(loc[2] for loc in locs)

    return (lo_i, hi_i, lo_j, hi_j)
end


function count_empty(elves::Vector{Elf})

    locs = [e.loc for e in elves]
    (lo_i, hi_i, lo_j, hi_j) = get_bounding_rectangle(elves)
    n_empty = 0

    for i in lo_i:hi_i
        for j in lo_j:hi_j
            (i,j) in locs ? nothing : n_empty += 1
        end
    end

    return n_empty
end


function show(elves::Vector{Elf})

    locs = [e.loc for e in elves]
    (lo_i, hi_i, lo_j, hi_j) = get_bounding_rectangle(elves)

    for i in lo_i:hi_i
        for j in lo_j:hi_j
            (i,j) in locs ? print('#') : print('.')
        end
        println()
    end
    println()
end


function is_terminated(elves::Vector{Elf})

    has_nbors = Bool[]

    for elf in elves
        loc = elf.loc
        nbors = [(i, j) for i in loc[1]-1:loc[1]+1 for j in loc[2]-1:loc[2]+1]
        has_nbor = any(e.loc in nbors for e in elves if e != elf)
        push!(has_nbors, has_nbor)
    end

    return !any(has_nbors)
end


# part 1

#filepath = "day23test.txt"
filepath = "day23.txt"
elves = parse_input(filepath)

for round in 1:10
    first_half!(elves)
    second_half!(elves)
end

n_empty = count_empty(elves)
println(n_empty)

# part 2
elves = parse_input(filepath)
terminated = false
round = 0

while !terminated
#for rep in 1:20
    global round += 1
    first_half!(elves)
    second_half!(elves)
    global terminated = is_terminated(elves)
    println(round)
    show(elves)
end

println(round + 1)
