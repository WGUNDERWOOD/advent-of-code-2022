println("Day 21")

mutable struct Monkey
    id::String
    expr::Union{String, Tuple{String, String, String}}
    parsed::Bool
end


function parse_input(filepath::String)

    file = readlines(filepath)
    monkeys = Dict{String, Monkey}()

    for l in file
        split_l = String.(split(l, [':',' ']))
        id = split_l[1]

        if all(s in '0':'9' for s in split_l[3])
            expr = split_l[3]
            parsed = true
        else
            expr = Tuple(split_l[3:5])
            parsed = false
        end

        monkey = Monkey(id, expr, parsed)
        push!(monkeys, id => monkey)
    end

    return monkeys
end


function update_expr!(id::String, monkeys::Dict{String, Monkey})

    if !monkeys[id].parsed
        a_id = monkeys[id].expr[1]
        b_id = monkeys[id].expr[3]

        if monkeys[a_id].parsed && monkeys[b_id].parsed
            a_expr = "(" * join(monkeys[a_id].expr) * ")"
            b_expr = "(" * join(monkeys[b_id].expr) * ")"
            op = monkeys[id].expr[2]
            monkeys[id].expr = (a_expr, op, b_expr)
            monkeys[id].parsed = true
        end
    end
end


# part 1
monkeys = parse_input("day21.txt")
new_monkeys = deepcopy(monkeys)
terminated = false

while !terminated
    for id in keys(new_monkeys)
        update_expr!(id, new_monkeys)
    end
    global terminated = all(monkey.parsed for monkey in values(new_monkeys))
end

answer = round(Int, eval(Meta.parse(join(new_monkeys["root"].expr))))
println("Part 1: ", answer)


# part 2
new_monkeys = deepcopy(monkeys)
terminated = false
new_monkeys["humn"] = Monkey("humn", "humn", true)

while !terminated
    for id in keys(new_monkeys)
        update_expr!(id, new_monkeys)
    end
    global terminated = all(monkey.parsed for monkey in values(new_monkeys))
end

if 'h' in new_monkeys["root"].expr[1]
    arrow = Meta.parse(new_monkeys["root"].expr[1])
    arrow = @eval (humn) -> $arrow
    target = round(Int, eval(Meta.parse(new_monkeys["root"].expr[3])))
else
    arrow = Meta.parse(new_monkeys["root"].expr[3])
    arrow = @eval (humn) -> $arrow
    target = round(Int, eval(Meta.parse(new_monkeys["root"].expr[1])))
end

# initial guesses
lo = -1
hi = 1

# expand binary search interval
while !(min(arrow(lo), arrow(hi)) <= target <= max(arrow(lo), arrow(hi)))
    global lo *= 2
    global hi *= 2
end

# run binary search on interval
while hi - lo > 1
    mid = div(lo + hi, 2)
    if min(arrow(lo), arrow(mid)) <= target <= max(arrow(lo), arrow(mid))
        global hi = mid
    else
        global lo = mid
    end
end

# print answers
if arrow(lo) == target
    answer = lo
elseif arrow(hi) == target
    answer = hi
end

println("Part 2: ", answer)
