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
end


function show(state::State)

    pad = 18
    println(rpad("Time: ", pad), state.time)
    println(rpad("  Ore: ", pad), state.n_ore)
    println(rpad("  Clay: ", pad), state.n_clay)
    println(rpad("  Obsidian: ", pad), state.n_obs)
    println(rpad("  Geodes: ", pad), state.n_geode)
    println(rpad("  Ore bots: ", pad), state.n_ore_bot)
    println(rpad("  Clay bots: ", pad), state.n_clay_bot)
    println(rpad("  Obsidian bots: ", pad), state.n_obs_bot)
    println(rpad("  Geode bots: ", pad), state.n_geode_bot)
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
        blueprint = Blueprint(id, cost_ore_bot, cost_clay_bot, cost_obs_bot, cost_geode_bot)
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
                 state.n_ore_bot, state.n_clay_bot, state.n_obs_bot, state.n_geode_bot)
end


function check_resources(option::Char, state::State, blueprint::Blueprint)

    if option == 'n'
        return true

    elseif option == 'o'
        return state.n_ore >= blueprint.cost_ore_bot

    elseif option == 'c'
        return state.n_ore >= blueprint.cost_clay_bot

    elseif option == 'b'
        return (state.n_ore >= blueprint.cost_obs_bot[1]) &&
            (state.n_clay >= blueprint.cost_obs_bot[2])

    elseif option == 'g'
        return (state.n_ore >= blueprint.cost_geode_bot[1]) &&
            (state.n_obs >= blueprint.cost_geode_bot[2])

    else
        error("invalid option")
    end
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

    else
        error("invalid option")
    end

    return State(state.time, new_n_ore, new_n_clay, new_n_obs, new_n_geode,
                 new_n_ore_bot, new_n_clay_bot, new_n_obs_bot, new_n_geode_bot)
end


function decision(option::Char, state::State, blueprint::Blueprint)

    new_state = collect_resources(state)
    new_state = build_robot(option, new_state, blueprint)
    return new_state
end




# check resources available
# collect_resources and increment time
# build robot



#parse_input("day19.txt")
blueprints = parse_input("day19test.txt")
blueprint = blueprints[1]
state = State(0, 0, 0, 0, 0, 1, 0, 0, 0)
show(state)

options = ['n', 'n', 'c', 'n', 'c', 'n', 'c', 'n', 'n', 'n', 'b', 'c', 'n',
           'n', 'b', 'n', 'n', 'g', 'n', 'n', 'g', 'n', 'n', 'n']

for option in options
    @assert check_resources(option, state, blueprint)
    global state = decision(option, state, blueprint)
    show(state)
end
