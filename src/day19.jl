println("Day 19")

struct Blueprint
    id::Int
    cost_ore_bot::Int
    cost_clay_bot::Int
    cost_obs_bot::Tuple{Int, Int}
    cost_geode_bot::Tuple{Int, Int}
end


struct State
    time::Int
    n_ore::Int
    n_clay::Int
    n_obs::Int
    n_geode::Int
    n_ore_bot::Int
    n_clay_bot::Int
    n_obs_bot::Int
    n_geode_bot::Int
    skipped_ore_bot::Bool
    skipped_clay_bot::Bool
    skipped_obs_bot::Bool
end


function parse_input(filepath::String)

    blueprints = Blueprint[]

    for l in readlines(filepath)
        s = String.(split(l, [' ', ':']))
        id = parse(Int, s[2])
        cost_ore_bot = parse(Int, s[8])
        cost_clay_bot = parse(Int, s[14])
        cost_obs_bot = parse.(Int, (s[20], s[23]))
        cost_geode_bot = parse.(Int, (s[29], s[32]))
        blueprint = Blueprint(id, cost_ore_bot, cost_clay_bot,
                              cost_obs_bot, cost_geode_bot)
        push!(blueprints, blueprint)
    end

    return blueprints
end


function collect_resources(state::State)

    new_time = state.time + 1
    new_n_ore = state.n_ore + state.n_ore_bot
    new_n_clay = state.n_clay + state.n_clay_bot
    new_n_obs = state.n_obs + state.n_obs_bot
    new_n_geode = state.n_geode + state.n_geode_bot

    return State(new_time, new_n_ore, new_n_clay, new_n_obs, new_n_geode,
                 state.n_ore_bot, state.n_clay_bot, state.n_obs_bot, state.n_geode_bot,
                 state.skipped_ore_bot, state.skipped_clay_bot, state.skipped_obs_bot)
end


function check_resource(option::Char, state::State, blueprint::Blueprint)

    if (state.n_ore >= blueprint.cost_geode_bot[1]) &&
        (state.n_obs >= blueprint.cost_geode_bot[2])
        return option == 'g'

    else
        if option == 'n'
            return true

        elseif option == 'o'
            return (!state.skipped_ore_bot) &&
                state.n_ore >= blueprint.cost_ore_bot

        elseif option == 'c'
            return (!state.skipped_clay_bot) &&
                state.n_ore >= blueprint.cost_clay_bot

        elseif option == 'b'
            return (!state.skipped_obs_bot) &&
                (state.n_ore >= blueprint.cost_obs_bot[1]) &&
                (state.n_clay >= blueprint.cost_obs_bot[2])

        elseif option == 'g'
            return false

        end
    end
end


function max_possible_geodes(state::State, limit::Int)
    time_remaining = limit - state.time
    return state.n_geode +
        time_remaining * state.n_geode_bot +
        div(time_remaining * (time_remaining - 1), 2)
end


function decision(option::Char, state::State, blueprint::Blueprint)

    skipped_ore_bot = (option == 'n') && check_resource('o', state, blueprint)
    skipped_clay_bot = (option == 'n') && check_resource('c', state, blueprint)
    skipped_obs_bot = (option == 'n') && check_resource('b', state, blueprint)

    new_state = State(state.time, state.n_ore, state.n_clay, state.n_obs, state.n_geode,
                     state.n_ore_bot, state.n_clay_bot, state.n_obs_bot, state.n_geode_bot,
                     skipped_ore_bot, skipped_clay_bot, skipped_obs_bot)

    new_state = collect_resources(new_state)
    new_state = build_robot(option, new_state, blueprint)
    return new_state
end


function build_robot(option::Char, state::State, blueprint::Blueprint)

    new_n_ore = state.n_ore
    new_n_clay = state.n_clay
    new_n_obs = state.n_obs
    new_n_geode = state.n_geode
    new_n_ore_bot = state.n_ore_bot
    new_n_clay_bot = state.n_clay_bot
    new_n_obs_bot = state.n_obs_bot
    new_n_geode_bot = state.n_geode_bot

    if option == 'n'
        nothing

    elseif option == 'o'
        new_n_ore -= blueprint.cost_ore_bot
        new_n_ore_bot += 1

    elseif option == 'c'
        new_n_ore -= blueprint.cost_clay_bot
        new_n_clay_bot += 1

    elseif option == 'b'
        new_n_ore -= blueprint.cost_obs_bot[1]
        new_n_clay -= blueprint.cost_obs_bot[2]
        new_n_obs_bot += 1

    elseif option == 'g'
        new_n_ore -= blueprint.cost_geode_bot[1]
        new_n_obs -= blueprint.cost_geode_bot[2]
        new_n_geode_bot += 1
    end

    return State(state.time, new_n_ore, new_n_clay, new_n_obs, new_n_geode,
                 new_n_ore_bot, new_n_clay_bot, new_n_obs_bot, new_n_geode_bot,
                 state.skipped_ore_bot, state.skipped_clay_bot, state.skipped_obs_bot)
end


function get_most_geodes(blueprint::Blueprint, limit::Int)

    most_geodes::Int = 0
    options = Char['n', 'o', 'c', 'b', 'g']
    checking = State[State(0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0)]
    checked = State[]

    max_required_ore::Int = max(blueprint.cost_ore_bot, blueprint.cost_clay_bot,
                                blueprint.cost_obs_bot[1], blueprint.cost_geode_bot[1])
    max_required_clay::Int = blueprint.cost_obs_bot[2]
    max_required_obs::Int = blueprint.cost_geode_bot[2]

    while length(checking) > 0

        state = pop!(checking)

        for option in options

            if check_resource(option, state, blueprint)

                new_state = decision(option, state, blueprint)
                time = new_state.time

                if (max_possible_geodes(new_state, limit) > most_geodes) &&
                    (new_state.n_obs_bot <= max_required_obs) &&
                    (new_state.n_clay_bot <= max_required_clay) &&
                    (new_state.n_ore_bot <= max_required_ore)

                    if new_state.time < limit
                        push!(checking, new_state)
                    else
                        push!(checked, new_state)
                    end

                    most_geodes = max(most_geodes, new_state.n_geode)
                end
            end
        end
    end

    return most_geodes
end


blueprints = parse_input("day19.txt")

# part 1
limit = 24
most_geodes_list = Int[0 for _ in 1:length(blueprints)]

for i in 1:length(blueprints)
    blueprint = blueprints[i]
    most_geodes = get_most_geodes(blueprint, limit)
    most_geodes_list[i] = most_geodes
end

println("Part 1: ",sum(i * most_geodes_list[i] for i in eachindex(blueprints)))


# part 2
limit = 32
most_geodes_list = Int[0 for _ in 1:3]

for i in 1:3
    blueprint = blueprints[i]
    most_geodes = get_most_geodes(blueprint, limit)
    most_geodes_list[i] = most_geodes
end

println("Part 2: ", prod(most_geodes_list))
println()
