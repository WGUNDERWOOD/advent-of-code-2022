struct Heightmap
    heights::Matrix{Int}
    S::Tuple{Int, Int}
    E::Tuple{Int, Int}
end


function parse_heightmap(filepath::String)

    file = readlines(filepath)
    m = length(file)
    n = length(file[1])
    heights = fill(0, (m, n))
    S = (0, 0)
    E = (0, 0)

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

    return Heightmap(heights, S, E)
end


function show(heightmap::Heightmap)

    println("Start: ", heightmap.S)
    println("End: ", heightmap.E)

    (m, n) = size(heightmap.heights)
    formatted_heights = Array{Union{Int, Char}}(undef, (m, n))

    for i in 1:m
        for j in 1:n
            if (i, j) == heightmap.S
                formatted_heights[i, j] = 'S'
            elseif (i, j) == heightmap.E
                formatted_heights[i, j] = 'E'
            else
                formatted_heights[i, j] = heightmap.heights[i, j]
            end
        end
    end

    display(formatted_heights)
end


struct Dijkstra
    distances::Matrix{Union{Int, Float64}}
    directions::Matrix{Union{Char, Nothing}}
end


function initialize_dijkstra(heightmap::Heightmap)

    (m, n) = size(heightmap.heights)
    distances = Array{Union{Int, Float64}}(undef, (m, n))
    distances .= Inf
    directions = Array{Union{Char, Nothing}}(nothing, (m, n))

    (i, j) = heightmap.S
    directions[i,j] = 's'
    distances[i,j] = Int(0)

    return Dijkstra(distances, directions)
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


function iterate!(dijkstra::Dijkstra, heightmap::Heightmap)

    (m, n) = size(heightmap.heights)

    for i in 1:m
        for j in 1:n

            distance = dijkstra.distances[i,j]

            if distance < Inf

                height = heightmap.heights[i,j]

                for (r, s) in neighbors(i, j, m, n)

                    new_height = heightmap.heights[r,s]
                    old_distance = dijkstra.distances[r,s]

                    if new_height <= height + 1
                        dijkstra.distances[r,s] = Int(min(distance + 1, old_distance))
                    end

                end
            end
        end
    end
end


function get_path_length(dijkstra::Dijkstra)



heightmap = parse_heightmap("height.txt")
dijkstra = initialize_dijkstra(heightmap)

while Inf in dijkstra.distances
    iterate!(dijkstra, heightmap)
    display(dijkstra.distances)
end

#show(heightmap)

println()
