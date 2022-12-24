mutable struct Chamber
    tower::Matrix{Char}
    const jets::Vector{Char}
    jet_ind::Int
    const rocks::Vector{Matrix{Char}}
    rock_ind::Int
    n_rocks::Int
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
    n_rocks = 0

    return Chamber(tower, jets, jet_ind, rocks, rock_ind, n_rocks)

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

    for i in 1:min(size(tower, 1), 10)
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
    else
        apply_jet!(chamber)
        apply_fall!(chamber)
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
                chamber.tower[i+4-size(rock, 1), j+3] = '@'
            end
        end
    end

    chamber.rock_ind = 1 + (chamber.rock_ind % length(chamber.rocks))
    chamber.n_rocks += 1
    return nothing
end


function apply_jet!(chamber::Chamber)

    at_locs = Tuple.(findall(x -> x == '@', chamber.tower))
    jet = chamber.jets[chamber.jet_ind]

    jet == '>' ? dir = 1 : dir = -1
    if all([chamber.tower[i, j + dir] in ['.', '@'] for (i, j) in at_locs])
        for loc in at_locs; chamber.tower[loc[1], loc[2]] = '.'; end
        for loc in at_locs; chamber.tower[loc[1], loc[2] + dir] = '@'; end
    end

    chamber.jet_ind = 1 + (chamber.jet_ind % length(chamber.jets))
    return nothing
end


function apply_fall!(chamber::Chamber)

    at_locs = Tuple.(findall(x -> x == '@', chamber.tower))

    if all([chamber.tower[i+1, j] in ['.', '@'] for (i, j) in at_locs])
        for loc in at_locs; chamber.tower[loc[1], loc[2]] = '.'; end
        for loc in at_locs; chamber.tower[loc[1]+1, loc[2]] = '@'; end
    else
        for loc in at_locs; chamber.tower[loc[1], loc[2]] = '#'; end
    end

    return nothing
end


function get_height(chamber::Chamber)

    hash_locs = Tuple.(findall(x -> x == '#', chamber.tower))
    top_hash = minimum(loc[1] for loc in hash_locs)
    return size(chamber.tower, 1) - top_hash
end


# part 1
#chamber = parse_input("day17.txt")
#chamber = parse_input("day17test.txt")
#n_rocks = 0

#while n_rocks <= 2022
    #iterate!(chamber)
    #global n_rocks = chamber.n_rocks
#end

#height = get_height(chamber)
#println(height)

# part 2

chamber = parse_input("day17.txt")
#chamber = parse_input("day17test.txt")
chambers = Chamber[]

for rep in 1:3e4
    iterate!(chamber)
    if chamber.jet_ind == 3 && chamber.rock_ind == 2 && rep >= 10
        push!(chambers, deepcopy(chamber))
    end
end


# Now we show that the two chambers picked are equivalent
# in the sense that the future pattern of blocks is the same.

# First verify the basic properties
@assert length(chambers) == 2
@assert chambers[1].jets == chambers[2].jets
@assert chambers[1].jet_ind == chambers[2].jet_ind
@assert chambers[1].rocks == chambers[2].rocks
@assert chambers[1].rock_ind == chambers[2].rock_ind

# Now check the falling rock is at least four squares wide
rock_ind = chambers[1].rock_ind
rock = chambers[1].rocks[rock_ind - 1]
@assert size(rock, 2) >= 4

# Now check the highest solid rock has no gaps larger than three
highest_rock_ind = minimum([loc[1] for loc in findall(x -> x == '#', chambers[1].tower)])
highest_rocks = chambers[1].tower[highest_rock_ind, :]

for i in 1:length(highest_rocks)-3
    @assert highest_rocks[i:i+3] != ['.', '.', '.', '.']
end

# Finally check that the two chamber towers look the same up to this point
@assert chambers[1].tower[1:highest_rock_ind,:] == chambers[2].tower[1:highest_rock_ind,:]

# Get the period (in units of rocks)
period = chambers[2].n_rocks - chambers[1].n_rocks
quotient = div(1000000000000, period)
remainder = 1000000000000 % period
period_height = get_height(chambers[2]) - get_height(chambers[1])

chamber = parse_input("day17.txt")
#chamber = parse_input("day17test.txt")

n_rocks = 0

while n_rocks <= remainder
    iterate!(chamber)
    global n_rocks = chamber.n_rocks
end

show(chamber)

println(n_rocks + quotient * period_height)

# 1514369502357 too high
# 1514369500652 too low
