println("Day 6")


function all_different(s::String)
    return length(unique(s)) == length(s)
end


function first_n_all_different(s::String, n::Int)

    for i in 1:length(s)-n+1
        if all_different(f[i:i+n-1])
            return i+n-1
        end
    end

    return nothing
end


f = readlines("day06.txt")[1]
println("Part 1: ", first_n_all_different(f, 4))
println("Part 2: ", first_n_all_different(f, 14))
println()
