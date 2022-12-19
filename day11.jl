println("Day 11")


mutable struct Monkey
    id::Int
    items::Vector{Dict{Int, Int}}
    operation::Function
    test::Int
    dest::Dict{Bool, Int}
    inspections::Int
end


function Monkey(ss::Vector{String}, div3::Bool)

    items = Dict{Int, Int}[]
    dest = Dict{Bool, Int}()
    divisors = [2, 3, 5, 7, 11, 13, 17, 19, 23]
    monkey = Monkey(0, items, x -> x, 0, dest, 0)

    for s in ss
        s_split = split(s, " ")

        if s_split[1] == "Monkey"
            id = parse(Int, replace(s_split[2], ":" => ""))
            monkey.id = id

        elseif s_split[3] == "Starting"
            for i in s_split[5:end]
                worry = parse(Int, replace(i, "," => ""))
                remainders = Dict{Int, Int}()
                for d in divisors
                    if div3
                        remainders[d] = worry
                    else
                        remainders[d] = rem(worry, d)
                    end
                end
                push!(items, remainders)
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
                test = parse(Int, s_split[6])
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


function parse_monkeys(filepath::String, div3::Bool)

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
    return [Monkey(m, div3) for m in monkeys_string]
end


function perform_round!(monkeys::Vector{Monkey}, div3::Bool)

    n = length(monkeys)

    for i in 1:n
        monkey = monkeys[i]
        items = monkey.items

        for j in 1:length(items)
            item = items[1]
            new_item = Dict{Int, Int}()
            for k in keys(item)
                new_item[k] = monkey.operation(item[k])
                if div3
                    new_item[k] = div(new_item[k], 3)
                else
                    new_item[k] = new_item[k] % k
                end
            end
            test_result = (new_item[monkey.test] % monkey.test == 0)
            target = monkey.dest[test_result]

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
    println("Items:")
    for item in monkey.items
        print("    ")
        for k in sort(collect(keys(item)))
            print(k, " => ", item[k], ", ")
        end
        println()
    end
    println("Inspections: ", monkey.inspections)
    println()
end


function most_active(k::Int, monkeys::Vector{Monkey})
    sorted_monkeys = sort(monkeys, by = x -> x.inspections, rev=true)
    return sorted_monkeys[1:k]
end


# Part 1
div3 = true
monkeys = parse_monkeys("day11.txt", div3)
n_rounds = 20

for rep in 1:n_rounds
    perform_round!(monkeys, div3)
end

active_monkeys = most_active(2, monkeys)
println("Part 1: ", prod([monkey.inspections for monkey in active_monkeys]))


# Part 2
div3 = false
monkeys = parse_monkeys("day11.txt", div3)
n_rounds = 10000

for rep in 1:n_rounds
    perform_round!(monkeys, div3)
end

active_monkeys = most_active(2, monkeys)
println("Part 2: ", prod([monkey.inspections for monkey in active_monkeys]))

println()
