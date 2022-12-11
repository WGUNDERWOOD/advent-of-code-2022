println("Day 7")

struct File
    name::String
    size::Int
    parent
end

struct Directory
    name::String
    size::Real
    directories::Vector{Directory}
    files::Vector{File}
    parent::Union{Directory, Nothing}
end

function cd(name::String, cwd::Directory)

    if name == "/"
        return "/"

    elseif name == ".."
        return cwd.parent

    else
        for dir in cwd.directories
            if dir.name == name
                return dir
            end
        end
    end

    error("Cannot cd: subdirectory not found")
end

function ls(cwd::Directory, filesystem::Dict)

end

filesystem = Dict("/" => Directory("/", NaN, Directory[], File[], nothing))
cwd = "/"


display(filesystem)



f = readlines("day07.txt")

for l in f[1:10]
    println(l)
end


#println("Part 1: ", first_n_all_different(f, 4))
#println("Part 2: ", first_n_all_different(f, 14))
