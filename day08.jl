function read_forest(filepath::String)

    file = readlines(filepath)
    m = length(file)
    n = length(file[1])
    forest = Matrix{Int}(undef, (m, n))

    for i in 1:m
        for j in 1:n
            forest[i,j] = parse(Int, file[i][j])
        end
    end

    return forest
end


function get_running_max(forest::Matrix{Int})

    (m, n) = size(forest)
    running_max = Matrix{Int}(undef, (m, n))

    for i in 1:m
        for j in 1:n
            if i == 1
                running_max[i,j] = forest[i,j]
            else
                running_max[i,j] = max(running_max[i-1,j], forest[i,j])
            end
        end
    end

    return running_max
end


function get_visibility_top(forest::Matrix{Int})

    (m, n) = size(forest)
    visibility = Array{Bool}(undef, (m, n))
    running_max = get_running_max(forest)

    for i in 1:m
        for j in 1:n

            if i == 1
                visibility[i,j] = true

            elseif forest[i,j] > running_max[i-1,j]
                visibility[i,j] = true

            else
                visibility[i,j] = false
            end
        end
    end

    return visibility
end


function get_visibility_direction(forest::Matrix{Int}, direction::String)

    if direction == "top"
        visibility = get_visibility_top(forest)
    end

    if direction == "bottom"
        visibility = reverse(forest)
        visibility = get_visibility_top(visibility)
        visibility = reverse(visibility)
    end

    if direction == "left"
        visibility = permutedims(forest, (2,1))
        visibility = get_visibility_top(visibility)
        visibility = permutedims(visibility, (2,1))
    end

    if direction == "right"
        visibility = reverse(permutedims(forest, (2,1)))
        visibility = get_visibility_top(visibility)
        visibility = permutedims(reverse(visibility), (2,1))
    end

    return visibility
end


function get_visibility(forest::Matrix{Int})

    top_visibility = get_visibility_direction(forest, "top")
    bottom_visibility = get_visibility_direction(forest, "bottom")
    left_visibility = get_visibility_direction(forest, "left")
    right_visibility = get_visibility_direction(forest, "right")

    visibility = top_visibility .|| bottom_visibility .||
        left_visibility .|| right_visibility

    return visibility
end


function get_scenic_score_top(forest::Matrix{Int})

    (m, n) = size(forest)
    scenic_score = Array{Int}(undef, (m, n))

    for i in 1:m
        for j in 1:n

            if i == 1
                scenic_score[i,j] = 0

            elseif forest[i,j] > forest[i-1,j]
                scenic_score[i,j] = scenic_score[i-1,j] + 1

            else
                scenic_score[i,j] = 1
            end

        end
    end

    return scenic_score
end


function get_scenic_score_direction(forest::Matrix{Int}, direction::String)

    if direction == "top"
        scenic_score = get_scenic_score_top(forest)
    end

    if direction == "bottom"
        scenic_score = reverse(forest)
        scenic_score = get_scenic_score_top(scenic_score)
        scenic_score = reverse(scenic_score)
    end

    if direction == "left"
        scenic_score = permutedims(forest, (2,1))
        scenic_score = get_scenic_score_top(scenic_score)
        scenic_score = permutedims(scenic_score, (2,1))
    end

    if direction == "right"
        scenic_score = reverse(permutedims(forest, (2,1)))
        scenic_score = get_scenic_score_top(scenic_score)
        scenic_score = permutedims(reverse(scenic_score), (2,1))
    end

    return scenic_score
end


function get_scenic_score(forest::Matrix{Int})

    top_scenic_score = get_scenic_score_direction(forest, "top")
    bottom_scenic_score = get_scenic_score_direction(forest, "bottom")
    left_scenic_score = get_scenic_score_direction(forest, "left")
    right_scenic_score = get_scenic_score_direction(forest, "right")

    scenic_score = top_scenic_score .* bottom_scenic_score .*
        left_scenic_score .* right_scenic_score

    return scenic_score
end





forest = read_forest("day08.txt")
#forest = read_forest("small_forest.txt")
visibility = get_visibility(forest)
display(sum(visibility))

scenic_score = get_scenic_score(forest)
display(maximum(scenic_score))
