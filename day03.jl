function split_in_half(s::String)
    midpoint = round(Int, length(s) / 2)
    first_half = s[1:midpoint]
    second_half = s[midpoint+1:end]
    return [first_half, second_half]
end


function shared_char(s1::String, s2::String)

    d = Dict()

    for a in s1
        d[a] = 1
    end

    for b in s2
        if haskey(d, b)
            return b
        end
    end
end


function char_value(c::Char)
    lower = collect("abcdefghijklmnopqrstuvwxyz")
    upper = collect("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    if c in lower
        return findfirst(x -> (x == c), lower)
    elseif c in upper
        return findfirst(x -> (x == c), upper) + 26
    end
end


open("day03.txt") do file
    priorities = Int[]
    for l in eachline(file)
        h = split_in_half(l)
        c = shared_char(h[1], h[2])
        push!(priorities, char_value(c))
    end
    println(sum(priorities))
end
