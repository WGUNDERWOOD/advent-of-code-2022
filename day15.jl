struct Sensor
    loc_x::Int
    loc_y::Int
    bea_x::Int
    bea_y::Int
    dist::Int
end


struct Interval
    lo::Union{Int, Nothing}
    hi::Union{Int, Nothing}
    proper::Bool
end


function parse_sensors(filename::String)

    file = readlines(filename)
    sensors = Sensor[]

    for l in file
        split_l = String.(split(l, [' ', '=', ',', ':']))
        loc_x = parse(Int, split_l[4])
        loc_y = parse(Int, split_l[7])
        bea_x = parse(Int, split_l[14])
        bea_y = parse(Int, split_l[17])
        dist = abs(loc_x - bea_x) + abs(loc_y - bea_y)
        sensor = Sensor(loc_x, loc_y, bea_x, bea_y, dist)
        push!(sensors, sensor)
    end

    return sensors
end


function impossible_x(y::Int, sensor::Sensor)

    y_dist = abs(y - sensor.loc_y)
    rem_dist = sensor.dist - y_dist

    if rem_dist >= 0
        lo = sensor.loc_x - rem_dist
        hi = sensor.loc_x + rem_dist
        return Interval(lo, hi, true)
    else
        return Interval(nothing, nothing, false)
    end
end


function simplify(i1::Interval, i2::Interval)

    if !i1.proper && !i2.proper
        return [Interval(nothing, nothing, false)]
    end

    if !i1.proper
        return [i2]
    end

    if !i2.proper
        return [i1]
    end

    if i1.lo > i2.lo
        return simplify(i2, i1)
    end

    if i1.hi < i2.lo
        return [i1, i2]
    else
        hi = max(i1.hi, i2.hi)
        return [Interval(i1.lo, hi, true)]
    end
end


function simplify(intervals::Vector{Interval})

    old_hash = hash(0)
    new_intervals = deepcopy(intervals)

    while hash(new_intervals) != old_hash
        old_hash = hash(new_intervals)
        n = length(new_intervals)
        for i in 1:n
            for j in 1:n
                if i < j
                    simple_intervals = simplify(new_intervals[i], new_intervals[j])
                    new_intervals[i] = simple_intervals[begin]
                    new_intervals[j] = simple_intervals[end]
                end
            end
        end
    end

    new_intervals = unique(new_intervals)
    return new_intervals
end


function cardinality(intervals::Vector{Interval})
    simple_intervals = simplify(intervals)
    return sum([i.hi - i.lo for i in simple_intervals])
end


# Part 1
#sensors = parse_sensors("signal.txt")
sensors = parse_sensors("day15.txt")
intervals = [impossible_x(2000000, sensor) for sensor in sensors]
println(cardinality(intervals))
