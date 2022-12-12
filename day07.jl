#println("Day 7")

struct Directory
    name::String
    size::Real
    directories::Vector{String}
    files::Vector{String}
    parent::Union{String, Nothing}
end

struct File
    name::String
    size::Int
    parent::Directory
end

mutable struct Filesystem
    structure::Dict
    cwd::String
end

function ls!(files::Vector{File}, directories::Vector{Directory}, fs::Filesystem)
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

        if !(fs.cwd in keys(fs.structure))
            fs.structure[fs.cwd] = Directory(fs.cwd, NaN, String[], String[], nothing)
        end

        return fs
    end

    error("Cannot cd: subdirectory not found")
end

function chunk_output(output::Vector(String))
end

#function ls(cwd::Directory, fs::Dict)

#end

fs = Filesystem(Dict("/" => Directory("/", NaN, String[], String[], nothing)), "/")
#cd!("/", fs)
#ls!([Directory("jmtrrrp", NaN, String[], String[], nothing)], [File("")] fs)


#cd!("jmtrrrp", fs)



f = readlines("day07.txt")

for i in 1:10
    l = f[i]
    println(l)
    l_split = split(l, " ")

    if l_split[1] == "\$"

        if l_split[2] == "cd"
            println("do cd stuff")
            name = String(l_split[3])
            cd!(name, fs)

        elseif l_split[2] == "ls"
            println("do ls stuff")

            for j in 1:10
                new_l = f[i+j]
                new_l_split = split(new_l, " ")
                if new_l_split[1] != "\$"
                    println("ls output")
                    println(new_l)
                end
            end
        end
    end
end


#println("Part 1: ", first_n_all_different(f, 4))
#println("Part 2: ", first_n_all_different(f, 14))
