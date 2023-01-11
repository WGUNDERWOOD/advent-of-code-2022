println("Day 20")

function parse_input(filepath::String)
    list = parse.(Int, readlines(filepath))
    indices = collect(1:length(list))
    return (list, indices)
end


function mix!(list::Vector{Int}, indices::Vector{Int}, index::Int)

    len = length(list)
    pos = [i for i in eachindex(list) if indices[i] == index][]
    number = list[pos]

    if number > 0
        new_pos = rem(pos + number - 1, len - 1, RoundDown) + 1
    elseif number < 0
        new_pos = rem(pos + number - 2, len - 1, RoundDown) + 2
    elseif number == 0
        return nothing
    end

    deleteat!(list, pos)
    insert!(list, new_pos, number)
    deleteat!(indices, pos)
    insert!(indices, new_pos, index)
    return nothing
end


function mix(list::Vector{Int}, indices::Vector{Int})

    len = length(list)
    new_list = copy(list)
    new_indices = copy(indices)

    for i in 1:len
        mix!(new_list, new_indices, i)
    end

    return (new_list, new_indices)
end


function answer(list::Vector{Int})
    len = length(list)
    index = findfirst(x -> x == 0, list)
    coords = [rem(i + index - 1, len) + 1 for i in [1000, 2000, 3000]]
    return sum(list[coords])
end


(list, indices) = parse_input("day20.txt")

# part 1
(new_list, new_indices) = mix(list, indices)
println("Part 1: ", answer(new_list))

# part 2
key = 811589153
(new_list, new_indices) = (list .* key, indices)

for rep in 1:10
    global (new_list, new_indices) = mix(new_list, new_indices)
end

println("Part 2: ", answer(new_list))
println()
