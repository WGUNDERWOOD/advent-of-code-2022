println("Day 21")

mutable struct Monkey
    id::String
    expr::Union{Vector{String}, Nothing}
    value::Union{Int, Nothing}
end


function parse_input(filepath::String)

    file = readlines(filepath)
    monkeys = Dict{String, Monkey}()

    for l in file
        split_l = String.(split(l, [':',' ']))
        id = split_l[1]

        if all(s in '0':'9' for s in split_l[3])
            expr = nothing
            value = parse(Int, split_l[3])
        else
            expr = split_l[3:5]
            value = nothing
        end

        monkey = Monkey(id, expr, value)
        push!(monkeys, monkey.id => monkey)
    end

    return monkeys
end


function update!(id::String, monkeys::Dict{String, Monkey})

    if isnothing(monkeys[id].value)
        a = monkeys[id].expr[1]
        op = monkeys[id].expr[2]
        b = monkeys[id].expr[3]
        a_val = monkeys[a].value
        b_val = monkeys[b].value

        if !isnothing(a_val) && !isnothing(b_val)
            if op == "+"
                monkeys[id].value = a_val + b_val
            elseif op == "-"
                monkeys[id].value = a_val - b_val
            elseif op == "*"
                monkeys[id].value = a_val * b_val
            elseif op == "/"
                monkeys[id].value = a_val / b_val
            end
        end
    end
end


#monkeys = parse_input("day21test.txt")
monkeys = parse_input("day21.txt")


# part 1
new_monkeys = deepcopy(monkeys)
terminated = false

while !terminated
    for id in keys(new_monkeys)
        update!(id, new_monkeys)
    end
    global terminated = all(!isnothing(monkey.value) for monkey in values(new_monkeys))
end

println(new_monkeys["root"].value)

# part 2
monkeys["humn"] = Monkey("humn", ["humn", "+", "0"], nothing)

for rep in 1:10000
    for id in keys(new_monkeys)
        update!(id, new_monkeys)
    end
end
display(monkeys)

#println(new_monkeys["root"].value)
