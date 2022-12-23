mutable struct Chamber
    tower::Matrix{Char}
    const jets::Vector{Char}
    jet_ind::Int
    const rocks::Vector{Matrix{Char}}
    rock_ind::Int
end


function parse_input(filepath::String)

    file = readlines(filepath)
    jets = only.(String.(split(file[1], "")))

    tower = ['|' '.' '.' '.' '.' '.' '.' '.' '|';
             '|' '.' '.' '.' '.' '.' '.' '.' '|';
             '|' '.' '.' '.' '.' '.' '.' '.' '|';
             '|' '.' '.' '.' '.' '.' '.' '.' '|';
             '+' '-' '-' '-' '-' '-' '-' '-' '-']

    jet_ind = 1

    rock1 = reshape(['#' '#' '#' '#'], 1, 4)
    rock2 = ['.' '#' '.'; '#' '#' '#'; '.' '#' '.']
    rock3 = ['.' '.' '#'; '.' '.' '#'; '#' '#' '#']
    rock4 = reshape(['#'; '#'; '#'; '#'], 4, 1)
    rock5 = ['#' '#'; '#' '#']
    rocks = Matrix{Char}[rock1, rock2, rock3, rock4, rock5]

    rock_ind = 1

    return Chamber(tower, jets, jet_ind, rocks, rock_ind)

end


function show(chamber::Chamber)

    println("Next jet: ", chamber.jets[chamber.jet_ind])

    println("Next rock: ")
    rock = chamber.rocks[chamber.rock_ind]

    for i in 1:size(rock, 1)
        print("  ")
        for j in 1:size(rock, 2)
            print(rock[i,j])
        end
        println()
    end

    println("Tower layout: ")
    tower = chamber.tower

    for i in 1:size(tower, 1)
        print("  ")
        for j in 1:size(tower, 2)
            print(tower[i,j])
        end
        println()
    end

    println()
    return nothing
end


function iterate!(chamber::Chamber)

    if !('@' in chamber.tower)
        adjust_height!(chamber)
        spawn_rock!(chamber)
    end

end


function adjust_height!(chamber::Chamber)

    empty_row = ['|', '.', '.', '.', '.', '.', '.', '.', '|']
    n_empty_rows = 0

    for i in 1:size(chamber.tower, 1)
        if chamber.tower[i,:] == empty_row
            n_empty_rows += 1
        else
            break
        end
    end

    n_extra_rows = 7 - n_empty_rows

    for i in 1:n_extra_rows
        chamber.tower = vcat(reshape(empty_row, 1, 9), chamber.tower)
    end

    return nothing
end


function spawn_rock!(chamber::Chamber)

    rock = chamber.rocks[chamber.rock_ind]

    for i in 1:size(rock, 1)
        for j in 1:size(rock, 2)
            if rock[i,j] == '#'
                chamber.tower[i, j+3] = '@'
            end
        end
    end

    return nothing
end

chamber = parse_input("day17.txt")
show(chamber)
iterate!(chamber)
show(chamber)
