println("Day 12")


struct Dijkstra
    heights::Matrix{Int}
    distances::Matrix{Union{Int, Float64}}
    visited::Matrix{Bool}
    S::Tuple{Int, Int}
    E::Tuple{Int, Int}
end


function parse_dijkstra(filepath::String)

    file = readlines(filepath)
    m = length(file)
    n = length(file[1])
    heights = fill(0, (m, n))
    S = (0, 0)
    E = (0, 0)

    # get heights
    for i in 1:m
        for j in 1:n

            h = file[i][j]

            if h == 'S'
                S = (i, j)
                heights[i,j] = 1

            elseif h == 'E'
                E = (i, j)
                heights[i,j] = 26

            else
                heights[i,j] = findfirst(h, String('a':'z'))

            end
        end
    end

    # get distances
    distances = Array{Union{Int, Float64}}(undef, (m, n))
    distances .= Inf
    (i, j) = E
    distances[i, j] = Int(0)

    # get visited
    visited = fill(false, (m, n))

    return Dijkstra(heights, distances, visited, S, E)
end


function show(dijkstra::Dijkstra)

    println("Start: ", dijkstra.S)
    println("End: ", dijkstra.E)

    (m, n) = size(dijkstra.heights)
    formatted_heights = Array{Union{Int, Char}}(undef, (m, n))

    for i in 1:m
        for j in 1:n
            if (i, j) == dijkstra.S
                formatted_heights[i, j] = 'S'
            elseif (i, j) == dijkstra.E
                formatted_heights[i, j] = 'E'
            else
                formatted_heights[i, j] = dijkstra.heights[i, j]
            end
        end
    end

    display(formatted_heights)
end


function neighbors(i::Int, j::Int, m::Int, n::Int)

    nbors = []

    @assert 0 <= i <= m
    @assert 0 <= j <= n

    if i-1 >= 1
        push!(nbors, (i-1, j))
    end

    if i+1 <= m
        push!(nbors, (i+1, j))
    end

    if j-1 >= 1
        push!(nbors, (i, j-1))
    end

    if j+1 <= n
        push!(nbors, (i, j+1))
    end

    return nbors
end


function closest_unvisited(dijkstra::Dijkstra)

    closest_distance = Inf
    best_coord = nothing
    (m, n) = size(dijkstra.heights)

    for i in 1:m
        for j in 1:n
            if !dijkstra.visited[i,j]
                distance = dijkstra.distances[i,j]
                if distance < closest_distance
                    closest_distance = distance
                    best_coord = (i, j)
                end
            end
        end
    end

    return best_coord
end


function terminated(dijkstra::Dijkstra)

    unvisited_distances = []
    (m, n) = size(dijkstra.heights)

    for i in 1:m
        for j in 1:n
            if !dijkstra.visited[i,j]
                distance = dijkstra.distances[i,j]
                push!(unvisited_distances, distance)
            end
        end
    end

    return minimum(unvisited_distances) == Inf
end


function iterate!(dijkstra::Dijkstra)

    (m, n) = size(dijkstra.heights)

    (i, j) = Tuple(closest_unvisited(dijkstra))
    distance = dijkstra.distances[i,j]
    height = dijkstra.heights[i,j]

    for (r, s) in neighbors(i, j, m, n)
        if !dijkstra.visited[r, s]

            new_height = dijkstra.heights[r,s]
            old_distance = dijkstra.distances[r,s]

            if new_height >= height - 1
                dijkstra.distances[r,s] = Int(min(distance + 1, old_distance))
            end

        end
    end

    dijkstra.visited[i, j] = true
end


function path_length_to_S(dijkstra::Dijkstra)

    (i, j) = dijkstra.S
    return dijkstra.distances[i, j]
end


function path_length_to_a(dijkstra::Dijkstra)

    (m, n) = size(dijkstra.heights)
    distances_to_a = []

    for i in 1:m
        for j in 1:n
            if dijkstra.heights[i, j] == 1
                push!(distances_to_a, dijkstra.distances[i, j])
            end
        end
    end

    return Int(minimum(distances_to_a))
end


dijkstra = parse_dijkstra("day12.txt")

while !terminated(dijkstra)
    iterate!(dijkstra)
end

println("Part 1: ", path_length_to_S(dijkstra))
println("Part 2: ", path_length_to_a(dijkstra))
println()
