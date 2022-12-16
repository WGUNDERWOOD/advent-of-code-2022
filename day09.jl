println("Day 9")

const Rope = Vector{Vector{Int64}}

Rope(n_knots::Int) = [[0,0] for _ in 1:n_knots]

function move_head!(motion::String, rope::Rope)

    motion == "L" ? rope[1][1] -= 1 : nothing
    motion == "R" ? rope[1][1] += 1 : nothing
    motion == "U" ? rope[1][2] += 1 : nothing
    motion == "D" ? rope[1][2] -= 1 : nothing

    return rope
end

function adjust_tail!(rope::Rope)

    n_knots = length(rope)

    for k in 1:n_knots-1
        distance = maximum(abs.(rope[k] .- rope[k+1]))
        if distance == 2
            rope[k+1] += sign.(rope[k] - rope[k+1])
        end
    end

    return rope
end

function parse_motions(filepath::String)

    file = readlines(filepath)
    motions = String[]

    for l in file
        split_l = split(l, " ")
        reps = parse(Int, split_l[2])
        append!(motions, [String(split_l[1]) for _ in 1:reps])
    end

    return motions
end


# Part 1
motions = parse_motions("day09.txt")
rope = Rope(2)
tail_positions = [rope[end]]

for m in motions
    move_head!(m, rope)
    adjust_tail!(rope)
    push!(tail_positions, copy(rope[end]))
end

println("Part 1: ", length(unique(tail_positions)))


# Part 2
rope = Rope(10)
tail_positions = [rope[end]]

for m in motions
    move_head!(m, rope)
    adjust_tail!(rope)
    push!(tail_positions, copy(rope[end]))
end

println("Part 2: ", length(unique(tail_positions)))
println()
