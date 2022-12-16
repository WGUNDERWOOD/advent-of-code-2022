#println("Day 11")


function make_item(worry::Int)

    item = Dict{Int, Int}()

    for divisor in divisors()
        item[divisor] = worry % divisor
    end

    return item
end


function make_item(item::Dict{Int, Int})

    new_item = Dict{Int, Int}()

    for divisor in divisors()
        println(divisor)
        new_item[divisor] = item[divisor] % divisor
    end

    return new_item
end


mutable struct Monkey
    id::Int
    items::Vector{Dict{Int, Int}}
    inspections::Int
end


function divisors()
    test_divisors = [23, 19, 13, 17]
    real_divisors = [2, 7, 3, 17, 11, 19, 5, 13]
    return sort(unique([test_divisors; real_divisors]))
end


function multiply_item(x::Int, item::Dict{Int, Int})

    new_item = copy(item)

    for k in keys(item)
        new_item[k] = item[k] * x
    end

    return new_item
end


function divide_by_3(item::Dict{Int, Int})

    new_item = copy(item)

    for k in keys(item)
        new_item[k] = div(item, 3)
    end

    return new_item
end


function initialize_monkeys()

    monkey0 = Monkey(0, make_item.([80]), 0)
    monkey1 = Monkey(1, make_item.([75, 83, 74]) , 0)
    monkey2 = Monkey(2, make_item.([86, 67, 61, 96, 52, 63, 73]), 0)
    monkey3 = Monkey(3, make_item.([85, 83, 55, 85, 57, 70, 85, 52]), 0)
    monkey4 = Monkey(4, make_item.([67, 75, 91, 72, 89]), 0)
    monkey5 = Monkey(5, make_item.([66, 64, 68, 92, 68, 77]), 0)
    monkey6 = Monkey(6, make_item.([97, 94, 79, 88]), 0)
    monkey7 = Monkey(7, make_item.([77, 85]), 0)

    return [monkey0, monkey1, monkey2, monkey3, monkey4, monkey5, monkey6, monkey7]
end


function decision_0(div3::Bool, item::Dict{Int, Int})

    if div3
        new_item = multiply_item(5, item)
        new_item = divide_by_3(new_item)
    else
        new_item = make_item(multiply_item(5, item))
    end

    test = (new_item[2] % 2 == 0)
    test ? target = 4 : target = 3

    return Dict("item" => item, "target" => target, "test" => test)
end


function decision_1(div3::Bool, item::Dict{Int, Int})

    if div3
        new_item = add_item(7, item)
        new_item = divide_by_3(new_item)
    else
        new_item = make_item(add_item(7, item))
    end

    test = (new_item[7] % 7 == 0)
    test ? target = 5 : target = 6

    return Dict("item" => item, "target" => target, "test" => test)
end

div3 = false
monkeys = initialize_monkeys()
println(monkeys[1].items[1])
decision_0(div3, monkeys[1].items[1])

#=
function decision(monkey::Monkey)


    if monkey.id == 1
        Starting items: 75, 83, 74
        Operation: new = old + 7
        Test: divisible by 7
        If true: throw to monkey 5
        If false: throw to monkey 6
    end

    if monkey.id == 2
        Starting items: 86, 67, 61, 96, 52, 63, 73
        Operation: new = old + 5
        Test: divisible by 3
        If true: throw to monkey 7
        If false: throw to monkey 0
    end

    if monkey.id == 3
        Starting items: 85, 83, 55, 85, 57, 70, 85, 52
        Operation: new = old + 8
        Test: divisible by 17
        If true: throw to monkey 1
        If false: throw to monkey 5
    end

    if monkey.id == 4
        Starting items: 67, 75, 91, 72, 89
        Operation: new = old + 4
        Test: divisible by 11
        If true: throw to monkey 3
        If false: throw to monkey 1
    end

    if monkey.id == 5
        Starting items: 66, 64, 68, 92, 68, 77
        Operation: new = old * 2
        Test: divisible by 19
        If true: throw to monkey 6
        If false: throw to monkey 2
    end

    if monkey.id == 6
        Starting items: 97, 94, 79, 88
        Operation: new = old * old
        Test: divisible by 5
        If true: throw to monkey 2
        If false: throw to monkey 7
    end

    if monkey.id == 7
        Starting items: 77, 85
        Operation: new = old + 6
        Test: divisible by 13
        If true: throw to monkey 4
        If false: throw to monkey 0
    end

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








function


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





# test divisors: 23, 19, 13, 17
# real divisors: 2, 7, 3, 17, 11, 19, 5, 13

=#
