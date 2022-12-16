mutable struct Rope
    head::Vector{Int64}
    tail::Vector{Int64}
end

Rope() = Rope([0,0], [0,0])

function move_head!(motion::String, rope::Rope)

    motion == "L" ? rope.head[1] -= 1 : nothing
    motion == "R" ? rope.head[1] += 1 : nothing
    motion == "U" ? rope.head[2] += 1 : nothing
    motion == "D" ? rope.head[2] -= 1 : nothing

    return rope
end

function adjust_tail!(rope::Rope)

    distance = maximum(abs.(rope.head .- rope.tail))

    if distance <= 1
        return rope

    elseif distance == 2
        rope.tail += sign.(rope.head - rope.tail)
        return rope

    else
        error("distance more than 2")
    end
end

function parse_motions(filepath::String)

    file = readlines(filepath)
    motions = String[]

    for l in file
        split_l = split(l, " ")
        reps = parse(Int, split_l[2])

        for i in 1:reps
            push!(motions, String(split_l[1]))
        end
    end

    return motions
end

rope = Rope()
motions = parse_motions("day09.txt")
tail_positions = [rope.tail]

for m in motions
    move_head!(m, rope)
    adjust_tail!(rope)
    push!(tail_positions, rope.tail)
end

println(rope)
display(length(unique(tail_positions)))
