#println("Day 11")


mutable struct Monkey
    id::Int
    items::Vector{Tuple{String, Int}}
    operation::Function
    test::Function
    dest::Dict{Bool, Int}
    inspections::Int
end


function Monkey(ss::Vector{String})

    items = Tuple{String, Int}[]
    dest = Dict{Bool, Int}()
    monkey = Monkey(0, items, x -> x, x -> x, dest, 0)

    for s in ss
        s_split = split(s, " ")

        if s_split[1] == "Monkey"
            id = parse(Int, replace(s_split[2], ":" => ""))
            monkey.id = id

        elseif s_split[3] == "Starting"
            for i in s_split[5:end]
                worry = parse(Int, replace(i, "," => ""))
                item_id = string(monkey.id) * "," * string(worry)
                push!(items, (item_id, worry))
            end
            monkey.items = items

        elseif s_split[3] == "Operation:"
            if s_split[4:5] == ["new", "="]
                expr = join(s_split[6:end], " ")
                expr  = "old -> "*expr
                operation = eval(Meta.parse(expr))
                monkey.operation = operation
            end

        elseif s_split[3] == "Test:"
            if s_split[4:5] == ["divisible", "by"]
                base = parse(Int, s_split[6])
                test = x -> (x % base == 0)
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


function perform_round!(monkeys::Vector{Monkey})

    n = length(monkeys)

    for i in 1:n
        monkey = monkeys[i]
        items = monkey.items

        for j in 1:length(items)
            item = items[1]
            item_id = item[1]
            worry = item[2]
            new_worry = monkey.operation(worry)
            new_worry = div(new_worry, 3)
            test_result = monkey.test(new_worry)
            target = monkey.dest[test_result]
            new_item = (item_id, new_worry)

            for target_monkey in monkeys
                if target_monkey.id == target
                    push!(target_monkey.items, new_item)
                end
            end

            popfirst!(monkey.items)
            monkey.inspections += 1
        end
    end
end


function show(monkey::Monkey)
    println("Monkey ID: ", monkey.id)
    println("Items: ", [item[2] for item in monkey.items])
    println("Inspections: ", monkey.inspections)
    println()
end


function most_active(k::Int, monkeys::Vector{Monkey})
    sorted_monkeys = sort(monkeys, by = x -> x.inspections, rev=true)
    return sorted_monkeys[1:k]
end


#monkeys = parse_monkeys("monkey.txt")
monkeys = parse_monkeys("day11.txt")
#show.(monkeys)

n_rounds = 20

for rep in 1:n_rounds
    perform_round!(monkeys)
end

# should be
# 27019168
# after 1000 rounds

#show.(monkeys)

active_monkeys = most_active(2, monkeys)
println(prod([monkey.inspections for monkey in active_monkeys]))

println()
