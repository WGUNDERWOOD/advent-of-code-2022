println("Day 18")

Cube = Tuple{Int, Int, Int}

function neighbors(cube::Cube)
    (i, j, k) = cube
    return [(i-1,j,k), (i+1,j,k), (i,j-1,k), (i,j+1,k), (i,j,k-1), (i,j,k+1)]
end


function parse_input(filepath::String)
    return [Tuple(parse.(Int, String.(split(l, ",")))) for l in readlines(filepath)]
end


function surface_area(cubes::Vector{Cube})

    total_area = 6 * length(cubes)
    contact_area = 0

    for cube in cubes
        for nbor in neighbors(cube)
            if nbor in cubes
                contact_area += 1
            end
        end
    end

    return total_area - contact_area
end


function get_boundary_cubes(cubes::Vector{Cube})

    lo = minimum([minimum(cube) for cube in cubes])
    hi = maximum([maximum(cube) for cube in cubes])

    e1 = [(i, j, k) for i in [lo,hi] for j in lo:hi for k in lo:hi]
    e2 = [(i, j, k) for i in lo:hi for j in [lo,hi] for k in lo:hi]
    e3 = [(i, j, k) for i in lo:hi for j in lo:hi for k in [lo,hi]]

    return [e1; e2; e3]
end


function get_all_cubes(cubes::Vector{Cube})

    lo = minimum([minimum(cube) for cube in cubes])
    hi = maximum([maximum(cube) for cube in cubes])
    return [(i, j, k) for i in lo:hi for j in lo:hi for k in lo:hi]
end


function complete(cubes::Vector{Cube})

    out_cubes = Cube[]
    check_cubes = [cube for cube in get_boundary_cubes(cubes) if !(cube in cubes)]
    lo = minimum([minimum(cube) for cube in cubes])
    hi = maximum([maximum(cube) for cube in cubes])

    while length(check_cubes) > 0
        cube = pop!(check_cubes)
        push!(out_cubes, cube)
        for nbor in neighbors(cube)
            if !(nbor in check_cubes) && !(nbor in out_cubes) &&
                all(lo .<= nbor .<= hi) && !(nbor in cubes)
                push!(check_cubes, nbor)
            end
        end
    end

    in_cubes = [cube for cube in get_all_cubes(cubes) if !(cube in out_cubes)]

    return in_cubes
end


# part 1
cubes = parse_input("day18.txt")
println("Part 1: ", surface_area(cubes))

# part 2
new_cubes = complete(cubes)
println("Part 2: ", surface_area(new_cubes))
println()
