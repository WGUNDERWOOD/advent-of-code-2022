println("Day 12")


struct Hill
    heights::Matrix{Int}
    distances::Matrix{Union{Int, Float64}}
    visited::Matrix{Bool}
    S::Tuple{Int, Int}
    E::Tuple{Int, Int}
end


function parse_hill(filepath::String)

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

    return Hill(heights, distances, visited, S, E)
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


function closest_unvisited(hill::Hill)

    closest_distance = Inf
    best_coord = nothing
    (m, n) = size(hill.heights)

    for i in 1:m
        for j in 1:n
            if !hill.visited[i,j]
                distance = hill.distances[i,j]
                if distance < closest_distance
                    closest_distance = distance
                    best_coord = (i, j)
                end
            end
        end
    end

    return best_coord
end


function terminated(hill::Hill)

    unvisited_distances = []
    (m, n) = size(hill.heights)

    for i in 1:m
        for j in 1:n
            if !hill.visited[i,j]
                distance = hill.distances[i,j]
                push!(unvisited_distances, distance)
            end
        end
    end

    return minimum(unvisited_distances) == Inf
end


function iterate!(hill::Hill)

    # Dijkstra's algorithm
    (m, n) = size(hill.heights)
    (i, j) = Tuple(closest_unvisited(hill))
    distance = hill.distances[i,j]
    height = hill.heights[i,j]

    for (r, s) in neighbors(i, j, m, n)
        if !hill.visited[r, s]

            new_height = hill.heights[r,s]
            old_distance = hill.distances[r,s]

            if new_height >= height - 1
                hill.distances[r,s] = Int(min(distance + 1, old_distance))
            end

        end
    end

    hill.visited[i, j] = true
end


function path_length_to_S(hill::Hill)

    (i, j) = hill.S
    return hill.distances[i, j]
end


function path_length_to_a(hill::Hill)

    (m, n) = size(hill.heights)
    distances_to_a = []

    for i in 1:m
        for j in 1:n
            if hill.heights[i, j] == 1
                push!(distances_to_a, hill.distances[i, j])
            end
        end
    end

    return Int(minimum(distances_to_a))
end


hill = parse_hill("day12.txt")

while !terminated(hill)
    iterate!(hill)
end

println("Part 1: ", path_length_to_S(hill))
println("Part 2: ", path_length_to_a(hill))
println()
