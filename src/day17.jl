println("Day 17")

mutable struct Chamber
    tower::Vector{Vector{Char}}
    const jets::Vector{Char}
    jet_ind::Int
    const rocks::Vector{Matrix{Char}}
    rock_ind::Int
    n_rocks::Int
    rock_height::Int
    n_reps::Int
end


function parse_input(filepath::String)

    file = readlines(filepath)
    jets = only.(String.(split(file[1], "")))

    tower = [['|', '.', '.', '.', '.', '.', '.', '.', '|'],
             ['|', '.', '.', '.', '.', '.', '.', '.', '|'],
             ['|', '.', '.', '.', '.', '.', '.', '.', '|'],
             ['|', '.', '.', '.', '.', '.', '.', '.', '|'],
             ['+', '-', '-', '-', '-', '-', '-', '-', '-']]

    jet_ind = 1

    rock1 = reshape(['#' '#' '#' '#'], 1, 4)
    rock2 = ['.' '#' '.'; '#' '#' '#'; '.' '#' '.']
    rock3 = ['.' '.' '#'; '.' '.' '#'; '#' '#' '#']
    rock4 = reshape(['#'; '#'; '#'; '#'], 4, 1)
    rock5 = ['#' '#'; '#' '#']
    rocks = Matrix{Char}[rock1, rock2, rock3, rock4, rock5]

    rock_ind = 1
    n_rocks = 0
    rock_height = 0
    n_reps = 0

    return Chamber(tower, jets, jet_ind, rocks, rock_ind, n_rocks, rock_height, n_reps)

end


function iterate!(chamber::Chamber)

    n_relevant_rows = min(length(chamber.tower), 50)

    if !(any('@' in row for row in chamber.tower[1:n_relevant_rows]))
        adjust_height!(chamber)
        spawn_rock!(chamber)
    else
        apply_jet!(chamber)
        apply_fall!(chamber)
    end

    chamber.n_reps += 1
    return nothing
end


function adjust_height!(chamber::Chamber)

    empty_row = ['|', '.', '.', '.', '.', '.', '.', '.', '|']
    n_empty_rows = 0

    for i in 1:length(chamber.tower)
        if chamber.tower[i] == empty_row
            n_empty_rows += 1
        else
            break
        end
    end

    n_extra_rows = 7 - n_empty_rows

    for _ in 1:n_extra_rows
        pushfirst!(chamber.tower, copy(empty_row))
    end

    return nothing
end


function spawn_rock!(chamber::Chamber)

    rock = chamber.rocks[chamber.rock_ind]

    for i in 1:size(rock, 1)
        for j in 1:size(rock, 2)
            if rock[i,j] == '#'
                chamber.tower[i+4-size(rock, 1)][j+3] = '@'
            end
        end
    end

    chamber.rock_ind = 1 + (chamber.rock_ind % length(chamber.rocks))
    chamber.n_rocks += 1
    return nothing
end


function get_at_locs(tower::Vector{Vector{Char}})

    n1 = min(length(tower), 50)
    n2 = length(tower[1])
    at_locs = Tuple{Int, Int}[]

    for i in 1:n1
        row = tower[i]
        for j in 1:n2
            if row[j] == '@'
                push!(at_locs, (i,j))
            end
        end
    end

    return at_locs
end


function apply_jet!(chamber::Chamber)

    at_locs = get_at_locs(chamber.tower)
    jet = chamber.jets[chamber.jet_ind]

    jet == '>' ? dir = 1 : dir = -1
    if all([chamber.tower[i][j + dir] in ['.', '@'] for (i, j) in at_locs])
        for loc in at_locs; chamber.tower[loc[1]][loc[2]] = '.'; end
        for loc in at_locs; chamber.tower[loc[1]][loc[2] + dir] = '@'; end
    end

    chamber.jet_ind = 1 + (chamber.jet_ind % length(chamber.jets))
    return nothing
end


function apply_fall!(chamber::Chamber)

    at_locs = get_at_locs(chamber.tower)

    if all([chamber.tower[i+1][j] in ['.', '@'] for (i, j) in at_locs])
        for loc in at_locs; chamber.tower[loc[1]][loc[2]] = '.'; end
        for loc in at_locs; chamber.tower[loc[1]+1][loc[2]] = '@'; end
    else
        for loc in at_locs; chamber.tower[loc[1]][loc[2]] = '#'; end
        top_hash = minimum(loc[1] for loc in at_locs)
        chamber.rock_height = length(chamber.tower) - top_hash
    end

    return nothing
end


function equivalent(chamber1::Chamber, chamber2::Chamber)

    jets_bool =  chamber1.jets == chamber2.jets
    jet_ind_bool = chamber1.jet_ind == chamber2.jet_ind
    rocks_bool = chamber1.rocks == chamber2.rocks
    rock_ind_bool = chamber1.rock_ind == chamber2.rock_ind

    rock = chambers[1].rocks[chamber1.rock_ind - 1]
    rock_width = size(rock, 2)

    n1 = length(chamber1.tower)
    highest_rock_ind = minimum([i for i in 1:n1 if '#' in chamber1.tower[i]])
    highest_rocks = chamber1.tower[highest_rock_ind]
    width_bool = true

    for i in 1:length(highest_rocks) - rock_width + 1
        width_bool = width_bool &&
            highest_rocks[i:i+rock_width-1] != ['.' for _ in 1:rock_width]
    end

    tower_bool = chamber1.tower[1:highest_rock_ind] ==
        chamber2.tower[1:highest_rock_ind]

    return jets_bool && jet_ind_bool && rocks_bool &&
        rock_ind_bool && width_bool && tower_bool
end


# part 1
chamber = parse_input("day17.txt")

while chamber.n_rocks <= 2022
    iterate!(chamber)
end

println("Part 1: ", chamber.rock_height)


# part 2
total_rocks = 1000000000000
chamber = parse_input("day17.txt")
chambers = Chamber[]

for rep in 1:3e4
    iterate!(chamber)
    if chamber.jet_ind == 3 && chamber.rock_ind == 2 && rep >= 10
        push!(chambers, deepcopy(chamber))
    end
end

@assert equivalent(chambers[1], chambers[2])

init_n_rocks = chambers[1].n_rocks
init_height = chambers[1].rock_height

period = chambers[2].n_rocks - chambers[1].n_rocks
height_per_period = (chambers[2].rock_height - chambers[1].rock_height)
n_periods = div(total_rocks - init_n_rocks, period)
inter_height = height_per_period * n_periods

remainder = (total_rocks - init_n_rocks) % period
chamber = deepcopy(chambers[1])

n_rocks = 0
while n_rocks <= remainder
    iterate!(chamber)
    global n_rocks = chamber.n_rocks - chambers[1].n_rocks
end

remainder_height = chamber.rock_height - chambers[1].rock_height
println("Part 2: ", init_height + inter_height + remainder_height)
println()
