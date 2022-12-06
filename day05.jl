println("Day 5")

function get_initial_stacks(file_contents)

    stacks_raw = file_contents[1:9]
    stacks = [Char[] for _ in 1:9]

    for i in 1:length(stacks_raw)
        for j in 1:length(stacks_raw[i])
            c = stacks_raw[i][j]
            if c in 'A':'Z'
                ind = parse(Int, stacks_raw[9][j])
                push!(stacks[ind], c)
            end
        end
    end

    return stacks
end


function get_instructions(file_contents)

    instructions_raw = file_contents[11:end]
    instructions = [Int[] for _ in 1:length(instructions_raw)]

    for i in 1:length(instructions)
        instruction = instructions_raw[i]
        instructions[i] = parse.(Int, split(instruction, " ")[[2,4,6]])
    end

    return instructions
end


function move_one_crate(stacks::Vector{Vector{Char}}, a::Int, b::Int)

    new_stacks = copy(stacks)
    moving_crate = new_stacks[a][1]
    popfirst!(new_stacks[a])
    pushfirst!(new_stacks[b], moving_crate)

    return new_stacks
end


function do_instruction(stacks::Vector{Vector{Char}}, instruction::Vector{Int})

    new_stacks = copy(stacks)

    for i in 1:instruction[1]
        new_stacks = move_one_crate(new_stacks, instruction[2], instruction[3])
    end

    return new_stacks
end


function move_many_crates(stacks::Vector{Vector{Char}}, instruction::Vector{Int})

    a = instruction[1]
    b = instruction[2]
    c = instruction[3]
    new_stacks = copy(stacks)
    moving_crates = new_stacks[b][1:a]

    for i in 1:a
        popfirst!(new_stacks[b])
        pushfirst!(new_stacks[c], moving_crates[a-i+1])
    end

    return new_stacks
end


function top_crates(stacks::Vector{Vector{Char}})
    chars = [stack[1] for stack in stacks]
    return String(chars)
end


open("day05.txt") do file
    file_contents = collect(eachline(file))
    stacks = get_initial_stacks(file_contents)
    instructions = get_instructions(file_contents)

    for instruction in instructions
        stacks = do_instruction(stacks, instruction)
    end
    println("Part 1: ", top_crates(stacks))
end


open("day05.txt") do file
    file_contents = collect(eachline(file))
    stacks = get_initial_stacks(file_contents)
    instructions = get_instructions(file_contents)

    for instruction in instructions
        stacks = move_many_crates(stacks, instruction)
    end
    println("Part 2: ", top_crates(stacks))
end

println()
