println("Day 13")


function parse_pairs(filepath::String)

    file = readlines(filepath)
    pairs = Vector{String}[]
    pair = String[]

    for l in file
        if l == ""
            push!(pairs,  pair)
            pair = []
        else
            push!(pair, l)
        end
    end

    push!(pairs, pair)

    return pairs
end


function parse_packets(filepath::String)

    packets = String[]
    file = readlines(filepath)

    for l in file
        if l != ""
            push!(packets, l)
        end
    end

    dividers = ["[[2]]", "[[6]]"]
    append!(packets, dividers)

    return packets
end


function string_to_vector(s::String)

    @assert s[1] == '['
    @assert s[end] == ']'
    s = s[2:end-1]

    if length(s) == 0
        return String[]
    end

    strings = String[]
    string = ""

    bracket_count = 0

    for c in s
        c == '[' ? bracket_count += 1 : nothing
        c == ']' ? bracket_count -= 1 : nothing
        if (bracket_count == 0) && (c == ',')
            push!(strings, string)
            string = ""
        else
            string = string * c
        end
    end

    push!(strings, string)

    return strings
end


function compare(left::Int, right::Int)

    if left < right
        return true
    elseif left > right
        return false
    else
        return nothing
    end

end


function compare(left::Vector{String}, right::Vector{String})

    common_length = min(length(left), length(right))

    for i in 1:common_length
        result = compare(left[i], right[i])
        if result == true
            return true
        elseif result == false
            return false
        end
    end

    if length(left) < length(right)
        return true
    elseif length(left) > length(right)
        return false
    else
        return nothing
    end
end


function isint(s::String)
    if length(s) > 0
        return all([c in '0':'9' for c in s])
    else
        return false
    end
end


function compare(left::String, right::String)

    l_int = isint(left)
    r_int = isint(right)

    if l_int && r_int
        return compare(parse(Int, left), parse(Int, right))

    elseif l_int && !r_int
        return compare([left], string_to_vector(right))

    elseif !l_int && r_int
        return compare(string_to_vector(left), [right])

    elseif !l_int && !r_int
        return compare(string_to_vector(left), string_to_vector(right))

    end
end


function key_indices(packets::Vector{String})

    ind1 = 0
    ind2 = 0

    for i in 1:length(packets)
        if packets[i] == "[[2]]"
            ind1 = i
        elseif packets[i] == "[[6]]"
            ind2 = i
        end
    end

    return [ind1, ind2]
end


# Part 1
pairs = parse_pairs("day13.txt")
correct = Int[]

for i in 1:length(pairs)
    pair = pairs[i]
    result = compare(pair[1], pair[2])
    if result
        push!(correct, i)
    end
end

println("Part 1: ", sum(correct))


# Part 2
packets = parse_packets("day13.txt")
sorted_packets = sort(packets, lt = ((x, y) -> compare(x, y)))
println("Part 2: ", prod(key_indices(sorted_packets)))
println()
