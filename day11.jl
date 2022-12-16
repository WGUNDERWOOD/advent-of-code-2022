#println("Day 11")

mutable struct Monkey
    id::Int
    items::Set{Int}
    operation::Function
    test::Function
    dest::Dict{Bool, Int}
end

mutable struct KeepAway
    monkeys::Vector{Monkey}
end

function Monkey(ss::Vector{String})

    items = Set(Int[])
    dest = Dict{Bool, Int}()
    monkey = Monkey(0, items, x -> x, x -> x, dest)

    for s in ss
        s_split = split(s, " ")

        if s_split[1] == "Monkey"
            id = parse(Int, replace(s_split[2], ":" => ""))
            monkey.id = id

        elseif s_split[3] == "Starting"
            for i in s_split[5:end]
                item = parse(Int, replace(i, "," => ""))
                push!(items, item)
            end
            monkey.items = items

        elseif s_split[3] == "Operation:"
            # TODO not working
            if s_split[4:7] == ["new", "=", "old", "*"]
                multiplier = parse(Int, s_split[8])
                operation = (x -> x * multiplier)
                monkey.operation = operation
            end

        elseif s_split[3] == "Test:"
            if s_split[4:5] == ["divisible", "by"]
                base = parse(Int, s_split[6])
                test = (x -> x % base)
            end
            monkey.test = test

        elseif s_split[5] == "If"
            bool = parse(Bool, replace(s_split[6], ":" => ""))
            target = parse(Int, s_split[10])
            dest[bool] = target
            monkey.dest = dest

        end
    end

    return monkey
end

function parse_monkeys(filepath::String)

    file = readlines(filepath)

    monkeys_string = Vector{String}[]
    monkey_string = String[]

    for l in file
        if l == ""
            push!(monkeys_string, monkey_string)
            monkey_string = String[]
        else
            push!(monkey_string, l)
        end
    end

    push!(monkeys_string, monkey_string)
    return [Monkey(m) for m in monkeys_string]
end




monkeys = parse_monkeys("monkey.txt")
display(monkeys)

#monkey = Monkey(0, Set([79, 98]), x -> x * 19, x -> x % 23, Dict(true => 2, false => 3))
