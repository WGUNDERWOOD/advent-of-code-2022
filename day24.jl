println("Day 24")

# down, up, right, left, wall
Blizzard = Matrix{Vector{Int}}
Blizzards = Vector{Blizzard}

# note off-by-one for Julian indexing
struct State
    loc::Tuple{Int, Int}
    time::Int
end

function parse_input(filepath::String)

    file = readlines(filepath)
    m = length(file)
    n = length(file[1])
    blizzard_start = Blizzard(undef, m, n)
    loc_start = (0, 0)
    loc_goal = (0, 0)

    for i in 1:m
        for j in 1:n

            if file[i][j] == '.'
                blizzard_start[i,j] = [0, 0, 0, 0, 0]
            elseif file[i][j] == 'v'
                blizzard_start[i,j] = [1, 0, 0, 0, 0]
            elseif file[i][j] == '^'
                blizzard_start[i,j] = [0, 1, 0, 0, 0]
            elseif file[i][j] == '>'
                blizzard_start[i,j] = [0, 0, 1, 0, 0]
            elseif file[i][j] == '<'
                blizzard_start[i,j] = [0, 0, 0, 1, 0]
            elseif file[i][j] == '#'
                blizzard_start[i,j] = [0, 0, 0, 0, 1]
            end

            if i == 1
                if file[i][j] == '.'
                    loc_start = (i, j)
                end
            end

            if i == m
                if file[i][j] == '.'
                    loc_goal = (i, j)
                end
            end
        end
    end

    return (loc_start, loc_goal, blizzard_start)
end


function show(blizzard::Blizzard)

    (m, n) = size(blizzard)

    for i in 1:m
        for j in 1:n

            if blizzard[i,j][5] == 1
                print('#')
            elseif sum(blizzard[i,j]) > 1
                print(sum(blizzard[i,j]))
            else
                if blizzard[i,j] == [0, 0, 0, 0, 0]
                    print('.')
                elseif blizzard[i,j] == [1, 0, 0, 0, 0]
                    print('v')
                elseif blizzard[i,j] == [0, 1, 0, 0, 0]
                    print('^')
                elseif blizzard[i,j] == [0, 0, 1, 0, 0]
                    print('>')
                elseif blizzard[i,j] == [0, 0, 0, 1, 0]
                    print('<')
                end
            end
        end

        println()
    end

    println()
end


function iterate(blizzard::Blizzard)

    (m, n) = size(blizzard)
    new_blizzard = deepcopy(blizzard)

    for i in 2:m-1
        for j in 2:n-1

            # down
            if blizzard[i, j][1] > 0
                if i < m-1
                    new_blizzard[i+1, j][1] += blizzard[i, j][1]
                else
                    new_blizzard[2, j][1] += blizzard[i, j][1]
                end
            end

            # up
            if blizzard[i, j][2] > 0
                if i > 2
                    new_blizzard[i-1, j][2] += blizzard[i, j][2]
                else
                    new_blizzard[m-1, j][2] += blizzard[i, j][2]
                end
            end

            # right
            if blizzard[i, j][3] > 0
                if j < n-1
                    new_blizzard[i, j+1][3] += blizzard[i, j][3]
                else
                    new_blizzard[i, 2][3] += blizzard[i, j][3]
                end
            end

            # left
            if blizzard[i, j][4] > 0
                if j > 2
                    new_blizzard[i, j-1][4] += blizzard[i, j][4]
                else
                    new_blizzard[i, n-1][4] += blizzard[i, j][4]
                end
            end

            new_blizzard[i, j][1:4] .-= blizzard[i, j][1:4]
        end
    end

    return new_blizzard
end


function get_blizzards(blizzard_start::Blizzard, limit::Int)

    blizzards = [blizzard_start]

    for t in 1:limit-1
        push!(blizzards, iterate(blizzards[end]))
    end

    return blizzards
end


function neighbors(loc::Tuple{Int, Int})
    (i, j) = loc
    return ((i,j), (i+1,j), (i-1,j), (i,j+1), (i,j-1))
end


function get_new_states(state::State, blizzards::Blizzards)

    time = state.time
    new_states = State[]
    blizzard = blizzards[time + 1]
    (m, n) = size(blizzard)

    for new_locs in neighbors(state.loc)
        (i, j) = new_locs
        if (1 <= i <= m) && (1 <= j <= n)
            if all(blizzard[i, j] .== 0)
                push!(new_states, State((i, j), time+1))
            end
        end
    end

    return new_states
end


function get_best_time(loc_start::Tuple{Int, Int}, loc_goal::Tuple{Int, Int},
                       blizzards::Blizzards, limit::Int)

    (m, n) = size(blizzards[1])
    lm = lcm(m, n)
    visited = Dict{Tuple{Tuple{Int, Int}, Int}, Bool}()
    state_start = State(loc_start, 1)
    checking = State[state_start]
    checked = State[]

    while length(checking) > 0

        state = pop!(checking)
        new_states = get_new_states(state, blizzards)

        for new_state in new_states
            if new_state.time < limit

                if !haskey(visited, (new_state.loc, new_state.time % lm))
                    if new_state.loc == loc_goal
                        push!(checked, new_state)
                    else
                        push!(checking, new_state)
                    end
                    visited[(new_state.loc, new_state.time % lm)] = true
                end
            end
        end
    end

    return minimum(state.time for state in checked)
end


filepath = "day24.txt"

(loc_start, loc_goal, blizzard_start) = parse_input(filepath)

limit1 = 260
blizzards1 = get_blizzards(blizzard_start, limit1)
time1 = get_best_time(loc_start, loc_goal, blizzards1, limit1)
println("Part 1: ", time1-1)

limit2 = 270
blizzards2 = get_blizzards(blizzards1[time1], limit2)
time2 = get_best_time(loc_goal, loc_start, blizzards2, limit2)

limit3 = 300
blizzards3 = get_blizzards(blizzards2[time2], limit3)
time3 = get_best_time(loc_start, loc_goal, blizzards3, limit3)

println("Part 2: ", time1 + time2 + time3 - 3)
println()
