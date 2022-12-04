function split_in_half(s::String)
    midpoint = round(Int, length(s) / 2)
    first_half = s[1:midpoint]
    second_half = s[midpoint+1:end]
    return [first_half, second_half]
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


function shared_chars(strings::Vector{String})

    if length(strings) >= 3
        return shared_chars([shared_chars(strings[1], strings[2]);
                            strings[3:end]])

    elseif length(strings) == 2

        s = Set(collect(strings[1]))
        shared = ""

        for a in strings[s]
            if a in s
                push(shared, a)
            end
        end

        return shared

    else
        return nothing

    end
end


open("day03.txt") do file
    priorities = Int[]
    for l in eachline(file)
        h = split_in_half(l)
        c = shared_chars(h)
        push!(priorities, char_value(c))
    end
    #display(sum(priorities))
end

open("day03.txt") do file
    r = collect(eachline(file))
    n_groups = round(Int, length(r) / 3)
    groups = [[r[i], r[i+1], r[i+2]] for i in 1:n_groups]
    #display(groups)
end
println()

# TODO display not println
