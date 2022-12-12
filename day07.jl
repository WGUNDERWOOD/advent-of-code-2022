#println("Day 7")

mutable struct Directory
    name::String
    size::Real
    directories::Vector{String}
    files::Vector{String}
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
    fs.structure[full_name] = Directory(full_name, 0, String[], String[], fs.cwd)
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

    error("Cannot cd: subdirectory not found")
end


function propagate_sizes!(fs::Filesystem)

    depth = maximum([count(x -> (x == '/'), o.name) for o in values(fs.structure)])

    for d in 1:depth
        for k in keys(fs.structure)
            dir = fs.structure[k]
            if isa(dir, Directory)
                dir.size += sum([fs.structure[d].size for d in dir.directories])
                dir.size += sum([fs.structure[f].size for f in dir.files])
            end
        end
    end
end


function large_directories(threshold::Int, fs::Filesystem)

    large_dirs = Directory[]

    for k in keys(fs.structure)
        object = fs.structure[k]
        if isa(object, Directory)
            if object.size >= threshold
                push!(large_dirs, object)
            end
        end
    end

    return large_dirs
end



f = readlines("day07.txt")
fs = Filesystem(Dict("/" => Directory("/", NaN, String[], String[], nothing)), "/")

for l in f

    println(l)
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

#display(fs)
#println(length(fs.structure))

propagate_sizes!(fs)
large = large_directories(100000, fs)
display(large)
println(sum([d.size for d in large]))

#display(fs.structure)

#println("Part 1: ", first_n_all_different(f, 4))
#println("Part 2: ", first_n_all_different(f, 14))
