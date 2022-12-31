println("Day 23")

mutable struct Elf
    id::Int
    prop_loc::Union{Tuple{Int, Int}, Nothing}
end


Elves = Matrix{Union{Elf, Nothing}}
Directions = Vector{Tuple{Int, Int}}


function parse_input(filepath)

    file = readlines(filepath)
    (m, n) = (length(file), length(file[1]))
    elves = Elves(nothing, m, n)
    id = 1

    for i in eachindex(file)
        for j in eachindex(file[i])
            if file[i][j] == '#'
                elves[i, j] = Elf(id, nothing)
                id += 1
            end
        end
    end

    directions = [(-1,0), (1,0), (0,-1), (0,1)]

    return (elves, directions)
end


function neighbors(i::Int, j::Int)
    return ((r, s) for r in i-1:i+1 for s in j-1:j+1 if (r, s) != (i, j))
end


function neighbors2(i::Int, j::Int)
    return ((r, s) for r in i-2:i+2 for s in j-2:j+2 if (r, s) != (i, j))
end

function adjacent(i::Int, j::Int, dir::Tuple{Int, Int})
    return ((i, j) .+ dir .+ a for a in ((0,0), reverse(dir), -1 .* reverse(dir)))
end


function resize_elves(elves::Elves, margin::Int)

    (m, n) = size(elves)
    left = reshape(elves[:, 1:2], :)
    right = reshape(elves[:, n-1:n], :)
    top = reshape(elves[1:2, :], :)
    bottom = reshape(elves[m-1:m, :], :)

    if any(!isnothing(e) for e in [left; right; top; bottom])
        new_elves = Elves(nothing, m + 2 * margin, n + 2 * margin)
        new_elves[1+margin:m+margin, 1+margin:n+margin] .= elves
        elves = new_elves
    end

    return elves
end


function first_half!(elves::Elves, directions::Directions)

    (m, n) = size(elves)

    for i in 1:m, j in 1:n
        if !isnothing(elves[i,j])

            elf = elves[i,j]
            elf.prop_loc = (i, j)

            if all(isnothing(elves[r,s]) for (r, s) in neighbors(i, j))
                elf.prop_loc = (i, j)

            else
                for dir in reverse(directions)
                    if all(isnothing(elves[r,s]) for (r, s) in adjacent(i, j, dir))
                        elf.prop_loc = (i, j) .+ dir
                    end
                end
            end
        end
    end
end


function second_half!(elves::Elves, directions::Directions)

    (m, n) = size(elves)

    for i in 1:m, j in 1:n
        elf = elves[i,j]
        if !isnothing(elf) && !isnothing(elf.prop_loc)

            prop_loc = elf.prop_loc

            if all(isnothing(elves[r,s]) || elves[r,s].prop_loc != prop_loc
                   for (r, s) in neighbors2(i, j))

                elves[i, j] = nothing
                elves[prop_loc[1], prop_loc[2]] = Elf(elf.id, nothing)
            end
        end
    end

    direction = popfirst!(directions)
    push!(directions, direction)
end


function get_bounding_rectangle(elves::Elves)

    (m, n) = size(elves)
    locs = [(i, j) for i in 1:m for j in 1:n if !isnothing(elves[i, j])]
    lo_i = minimum(i for (i, j) in locs)
    hi_i = maximum(i for (i, j) in locs)
    lo_j = minimum(j for (i, j) in locs)
    hi_j = maximum(j for (i, j) in locs)

    return (lo_i, hi_i, lo_j, hi_j)
end


function count_empty(elves::Elves)

    (lo_i, hi_i, lo_j, hi_j) = get_bounding_rectangle(elves)
    n_empty = 0

    for i in lo_i:hi_i
        for j in lo_j:hi_j
            isnothing(elves[i,j]) ? n_empty += 1 : nothing
        end
    end

    return n_empty
end


function show(elves::Elves)

    (lo_i, hi_i, lo_j, hi_j) = get_bounding_rectangle(elves)

    for i in lo_i:hi_i
        for j in lo_j:hi_j
            isnothing(elves[i,j]) ? print('.') : print('#')
        end
        println()
    end
    println()
end


function is_terminated(elves::Elves)

    (m, n) = size(elves)

    for i in 1:m, j in 1:n
        elf = elves[i,j]
        if !isnothing(elf)
            if any(!isnothing(elves[r,s]) for (r, s) in neighbors(i, j))
                return false
            end
        end
    end

    return true
end


function iterate_rounds!(elves::Elves, directions::Directions, n_rounds::Int)

    for round in 1:n_rounds
        elves = resize_elves(elves, 10)
        first_half!(elves, directions)
        second_half!(elves, directions)
    end

    return (elves, directions)
end


function iterate_to_termination!(elves::Elves, directions::Directions)

    terminated = false
    round = 0

    while !terminated
        round += 1
        elves = resize_elves(elves, 10)
        first_half!(elves, directions)
        second_half!(elves, directions)
        terminated = is_terminated(elves)
    end

    return (elves, directions, round)
end


# part 1
filepath = "day23.txt"
(elves, directions) = parse_input(filepath)
(elves, directions) = iterate_rounds!(elves, directions, 10)
n_empty = count_empty(elves)
println(n_empty)

# part 2
(elves, directions) = parse_input(filepath)
(elves, directions, round) = iterate_to_termination!(elves, directions)
println(round + 1)
println()
