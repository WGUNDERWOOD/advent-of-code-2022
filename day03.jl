function split_in_half(s::String)
    midpoint = round(Int, length(s) / 2)
    first_half = s[1:midpoint]
    second_half = s[midpoint+1:end]
    return [first_half, second_half]
end


function char_value(c::Char)

    @assert length(c) == 1
    lower = collect("abcdefghijklmnopqrstuvwxyz")
    upper = collect("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    if c in lower
        return findfirst(x -> (x == c), lower)
    elseif c in upper
        return findfirst(x -> (x == c), upper) + 26
    end
end


function shared_string(strings::Vector{String})

    if length(strings) == 0
        return nothing

    elseif length(strings) == 1
        return strings[1]

    elseif length(strings) == 2
        s1 = Set(collect(strings[1]))
        s2 = Set(collect(strings[2]))
        return String(collect(intersect(s1, s2)))

    elseif length(strings) >= 3
        s = shared_string([shared_string(strings[1:2]); strings[3:end]])
        return s

    end
end


open("day03.txt") do file
    rucksacks = collect(eachline(file))
    halves = split_in_half.(rucksacks)
    shared = shared_string.(halves)
    priorities = char_value.(only.(shared))
    display(sum(priorities))
end

open("day03.txt") do file
    r = collect(eachline(file))
    n_groups = round(Int, length(r) / 3)
    groups = [[r[3*i-2], r[3*i-1], r[3*i]] for i in 1:n_groups]
    badges = shared_string.(groups)
    priorities = char_value.(only.(badges))
    display(sum(priorities))
end
