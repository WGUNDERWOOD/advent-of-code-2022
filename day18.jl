#Cube = Tuple{UInt8, UInt8, UInt8}
Cube = Tuple{Int, Int, Int}

function neighbors(cube::Cube)

    (i, j, k) = cube
    nbors = Cube[]

    push!(nbors, (i-1,j,k))
    push!(nbors, (i+1,j,k))
    push!(nbors, (i,j-1,k))
    push!(nbors, (i,j+1,k))
    push!(nbors, (i,j,k-1))
    push!(nbors, (i,j,k+1))

    return nbors
end


struct Droplet
    cubes::Vector{Cube}
    edges::Vector{Tuple{Cube, Cube}}
end


function parse_input(filepath::String)

    file = readlines(filepath)
    cubes = Cube[]
    edges = Tuple{Cube, Cube}[]

    for i in 1:length(file)

        l = file[i]
        split_l = String.(split(l, ","))
        cube = Tuple(parse.(Int, split_l))
        push!(cubes, cube)

        for nbor in neighbors(cube)
            if nbor in cubes
                push!(edges, (nbor, cube))
            end
        end
    end

    return Droplet(cubes, edges)
end


function exterior_surface_area(droplet::Droplet)

    total_area = 6 * length(droplet.cubes)
    contact_area = 2 * length(droplet.edges)
    return total_area - contact_area
end


# part 1
#droplet = parse_input("day18test.txt")
droplet = parse_input("day18.txt")
println(exterior_surface_area(droplet))

# part 2
