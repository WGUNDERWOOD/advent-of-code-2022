println("Day 7")

mutable struct Directory
    name::String
    size::Real
    parent::Union{String, Nothing}
end


struct File
    name::String
    size::Int
    parent::String
end


mutable struct Filesystem
    structure::Dict{String, Union{File, Directory}}
    cwd::String
end


function add_file!(name::String, size::Int, fs::Filesystem)
    full_name = fs.cwd * "/" * name
    full_name = replace(full_name, "//" => "/")
    fs.structure[full_name] = File(full_name, size, fs.cwd)
end


function add_directory!(name::String, fs::Filesystem)
    full_name = fs.cwd * "/" * name
    full_name = replace(full_name, "//" => "/")
    fs.structure[full_name] = Directory(full_name, NaN, fs.cwd)
end


function cd!(name::String, fs::Filesystem)

    if name == "/"
        fs.cwd = "/"
        return fs

    elseif name == ".."
        fs.cwd = fs.structure[fs.cwd].parent
        return fs

    else
        old_cwd = fs.cwd
        new_cwd = old_cwd * "/" * name
        fs.cwd = replace(new_cwd, "//" => "/")

        return fs
    end
end


function propagate_sizes!(fs::Filesystem)

    depth = maximum([count(x -> (x == '/'), o.name) for o in values(fs.structure)])

    for d in 1:depth
        for dir in values(fs.structure)
            if isa(dir, Directory) && isnan(dir.size)
                children = [x for x in values(fs.structure) if x.parent == dir.name]
                if !isempty(children)
                    if all([!isnan(x.size) for x in children])
                        dir.size = sum(x.size for x in children)
                    end
                end
            end
        end
    end
end


function size_of_small_directories(threshold::Int, fs::Filesystem)
    sizes = [x.size for x in values(fs.structure) if isa(x, Directory)]
    small_sizes = [x for x in sizes if x <= threshold]
    return sum(small_sizes)
end


function size_of_directory_to_delete(space_needed::Int, fs::Filesystem)
    sizes = [x.size for x in values(fs.structure) if isa(x, Directory)]
    large_enough_sizes = [x for x in sizes if x >= space_needed]
    return minimum(large_enough_sizes)
end


f = readlines("day07.txt")
fs = Filesystem(Dict("/" => Directory("/", NaN, nothing)), "/")

# Build filesystem

for l in f

    l_split = split(l, " ")

    if l_split[1] == "\$" && l_split[2] == "cd"
        name = String(l_split[3])
        cd!(name, fs)

    elseif l_split[1] != "\$"

        if l_split[1] == "dir"
            name = String(l_split[2])
            add_directory!(name, fs)

        else
            name = String(l_split[2])
            size = parse(Int, l_split[1])
            add_file!(name, size, fs)

        end
    end
end

# Get the right directory sizes
propagate_sizes!(fs)

# Part 1
println("Part 1: ", size_of_small_directories(100000, fs))

# Part 2
space_needed = fs.structure["/"].size - 40000000
println("Part 2: ", size_of_directory_to_delete(space_needed, fs))
println()
