function noop!(register)
    push!(register, register[end])
end

function addx!(v, register)
    noop!(register)
    push!(register, register[end] + v)
end

# Part 1
file = readlines("day10.txt")
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

# Part 1
cycles = [20, 60, 100, 140, 180, 220]
println("Part 1: ", sum(cycles .* register[cycles]))

println("Part 2:")
for i in 1:length(register)-1

    position = (i-1) % 40

    if abs(position - register[i]) <= 1
        print("■■")
    else
        print("  ")
    end

    if position == 39
        println()
    end
end
