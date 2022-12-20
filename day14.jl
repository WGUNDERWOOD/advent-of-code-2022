println("Day 14")

mutable struct Cave
    paths::Vector{Vector{Tuple{Int, Int}}}
    layout::Matrix{Char}
    current::Tuple{Int, Int}
    const start::Tuple{Int, Int}
    terminated::Bool
end


function parse_paths(filepath::String)

    file = readlines(filepath)
    paths = Vector{Tuple{Int, Int}}[]

    for l in file
        path = Tuple{Int, Int}[]
        sl = String.(split(l))

        for p in sl
            if p != "->"
                sp = String.(split(p, ","))
                x = parse(Int, sp[1])
                y = parse(Int, sp[2])
                push!(path, (x, y))
            end
        end
        push!(paths, path)
    end

    return paths
end


function parse_cave(paths::Vector{Vector{Tuple{Int, Int}}})

    # cave size
    max_x = maximum([maximum([node[1] for node in path]) for path in paths])
    max_x = max(max_x, 500)

    max_y = maximum([maximum([node[2] for node in path]) for path in paths])
    max_y = max(max_y, 0)

    min_x = minimum([minimum([node[1] for node in path]) for path in paths])
    min_x = min(min_x, 500)

    min_y = minimum([minimum([node[2] for node in path]) for path in paths])
    min_y = min(min_y, 0)

    size_x = max_x - min_x + 3
    size_y = max_y - min_y + 3

    # sand falls from start
    start_x = 500 - min_x + 2
    start_y = 0 - min_y + 2
    start = (start_x, start_y)
    current = start
    terminated = false

    # layout
    layout = Array{Char}(undef, (size_x, size_y))
    layout .= '.'
    layout[start_x, start_y] = '+'

    for path in paths
        for k in 1:length(path)-1

            node1 = path[k]
            node2 = path[k+1]

            if node1[1] == node2[1]
                x = node1[1] - min_x + 2
                y_min = min(node1[2], node2[2]) - min_y + 2
                y_max = max(node1[2], node2[2]) - min_y + 2
                layout[x, y_min:y_max] .= '#'
            elseif node1[2] == node2[2]
                x_min = min(node1[1], node2[1]) - min_x + 2
                x_max = max(node1[1], node2[1]) - min_x + 2
                y = node1[2] - min_y + 2
                layout[x_min:x_max, y] .= '#'
            end
        end
    end

    return Cave(paths, layout, current, start, terminated)
end


function iterate_cave!(cave::Cave)

    (c1, c2) = cave.current
    (s1, s2) = cave.start

    if c2 == size(cave.layout)[2]
        cave.terminated = true

    elseif cave.layout[c1, c2 + 1] == '.'
        cave.current = (c1, c2 + 1)
        cave.layout[c1, c2] = '.'
        cave.layout[s1, s2] = '+'
        cave.layout[c1, c2 + 1] = 'c'

    elseif cave.layout[c1 - 1, c2 + 1] == '.'
        cave.current = (c1 - 1, c2 + 1)
        cave.layout[c1, c2] = '.'
        cave.layout[s1, s2] = '+'
        cave.layout[c1 - 1, c2 + 1] = 'c'

    elseif cave.layout[c1 + 1, c2 + 1] == '.'
        cave.current = (c1 + 1, c2 + 1)
        cave.layout[c1, c2] = '.'
        cave.layout[s1, s2] = '+'
        cave.layout[c1 + 1, c2 + 1] = 'c'

    else
        cave.layout[c1, c2] = 'o'
        if cave.current == cave.start
            cave.terminated = true
        else
            cave.current = cave.start
            cave.layout[s1, s2] = '+'
        end

    end

    return nothing
end


function add_floor!(paths)
    max_x = maximum([maximum([node[1] for node in path]) for path in paths])
    min_x = minimum([minimum([node[1] for node in path]) for path in paths])
    max_y = maximum([maximum([node[2] for node in path]) for path in paths])
    h = 500
    path = [(min_x - h, max_y + 2), (max_x + h, max_y + 2)]
    push!(paths, path)
    return nothing
end


function show(cave::Cave)

    (size_x, size_y) = size(cave.layout)

    for y in 1:size_y
        for x in 1:size_x
            print(cave.layout[x,y])
        end
        println()
    end
    println()
end


function count_sand(cave::Cave)
    return sum(cave.layout .== 'o')
end


# Part 1
paths = parse_paths("day14.txt")
cave = parse_cave(paths)

while !cave.terminated
    iterate_cave!(cave)
end

println("Part 1: ", count_sand(cave))


# Part 2
add_floor!(paths)
cave = parse_cave(paths)

while !cave.terminated
    iterate_cave!(cave)
end

println("Part 2: ", count_sand(cave))
println()
