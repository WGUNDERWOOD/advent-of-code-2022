function noop!(register)
    push!(register, register[end])
    return nothing
end

function addx!(v, register)
    noop!(register)
    push!(register, register[end] + v)
end

#file = readlines("day10.txt")
file = readlines("small_register.txt")
register = [1]

for l in file
    split_l = split(l, " ")

    if split_l[1] == "noop"
        noop!(register)
    elseif split_l[1] == "addx"
        v = parse(Int, split_l[2])
        addx!(v, register)
    end
end

cycles = [20, 60, 100, 140, 180, 220]
println(sum(cycles .* register[cycles]))
