println("Day 10")

function noop!(register::Vector{Int})
    push!(register, register[end])
    return nothing
end

function addx!(v::Int, register::Vector{Int})
    noop!(register)
    push!(register, register[end] + v)
    return nothing
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

# Part 2
n_rows = div(length(register), 40)
output = Matrix{Char}(undef, n_rows, 40)
row = 1

for i in 1:length(register)-1

    position = (i-1) % 40

    if abs(position - register[i]) <= 1
        output[row, position + 1] = '#'
    else
        output[row, position + 1] = ' '
    end

    if position == 39
        global row += 1
    end
end

chars = Vector{String}(undef, 8)

for b in 1:8
    block = output[:, (5*b-4):(5*b-1)]

    if block == ['#' '#' '#' '#'; '#' ' ' ' ' ' '; '#' '#' '#' ' ';
                 '#' ' ' ' ' ' '; '#' ' ' ' ' ' '; '#' '#' '#' '#']
        chars[b] = "E"

    elseif block == ['#' '#' '#' '#'; '#' ' ' ' ' ' '; '#' '#' '#' ' ';
                     '#' ' ' ' ' ' '; '#' ' ' ' ' ' '; '#' ' ' ' ' ' ']
        chars[b] = "F"

    elseif block == ['#' ' ' ' ' '#'; '#' ' ' ' ' '#'; '#' ' ' ' ' '#';
                     '#' ' ' ' ' '#'; '#' ' ' ' ' '#'; ' ' '#' '#' ' ']
        chars[b] = "U"

    elseif block == [' ' '#' '#' ' '; '#' ' ' ' ' '#'; '#' ' ' ' ' ' ';
                     '#' ' ' '#' '#'; '#' ' ' ' ' '#'; ' ' '#' '#' '#']
        chars[b] = "G"

    elseif block == ['#' ' ' ' ' ' '; '#' ' ' ' ' ' '; '#' ' ' ' ' ' ';
                     '#' ' ' ' ' ' '; '#' ' ' ' ' ' '; '#' '#' '#' '#']
        chars[b] = "L"

    elseif block == ['#' '#' '#' ' '; '#' ' ' ' ' '#'; '#' ' ' ' ' '#';
                     '#' '#' '#' ' '; '#' ' ' ' ' ' '; '#' ' ' ' ' ' ']
        chars[b] = "P"

    elseif block == [' ' '#' '#' ' '; '#' ' ' ' ' '#'; '#' ' ' ' ' '#';
                     '#' '#' '#' '#'; '#' ' ' ' ' '#'; '#' ' ' ' ' '#']
        chars[b] = "A"

    end
end

println("Part 2: ", join(chars))
println()
