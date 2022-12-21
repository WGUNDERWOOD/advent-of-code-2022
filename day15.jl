println("Day 15")

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


function intersects(sensor1::Sensor, sensor2::Sensor)

    loc_x1 = sensor1.loc_x
    loc_y1 = sensor1.loc_y
    dist1 = sensor1.dist
    loc_x2 = sensor2.loc_x
    loc_y2 = sensor2.loc_y
    dist2 = sensor2.dist

    points = Tuple{Int, Int}[]

    for i1 in [-1, 1], i2 in [-1, 1], i3 in [-1, 1]
        x = i2 * (loc_x1 + loc_x2) + (loc_y2 - loc_y1) + i3 * dist2 + i1 * dist1
        x = i2 * x / 2
        y = i2 * x - i2 * loc_x1 + loc_y1 - i1 * dist1

        if abs(x - loc_x1) + abs(y - loc_y1) <= dist1 + 1
            if abs(x - loc_x2) + abs(y - loc_y2) <= dist2 + 1
                x = round(Int, x)
                y = round(Int, y)
                push!(points, (x, y))
            end
        end
    end

    return unique(points)
end


function intersects(sensors::Vector{Sensor})
    inter = Tuple{Int, Int}[]
    for s1 in sensors, s2 in sensors
        if s1 != s2
            append!(inter, intersects(s1, s2))
        end
    end

    return unique(inter)
end


function isin(point::Tuple{Int, Int}, sensor::Sensor)
    (x, y) = point
    return abs(x - sensor.loc_x) + abs(y - sensor.loc_y) <= sensor.dist
end


function neighbors(point::Tuple{Int, Int})

    (x, y) = point
    nbors = Tuple{Int, Int}[]

    for i in x-1:x+1
        for j in y-1:y+1
            push!(nbors, (i, j))
        end
    end

    return nbors
end


function not_covered(sensors::Vector{Sensor}, lim::Int)

    inter = intersects(sensors)
    uncovered = Tuple{Int, Int}[]

    for p in inter
        for n in neighbors(p)
            if (0 <= n[1] <= lim) && (0 <= n[2] <= lim)
                covered = Bool[]
                for s in sensors
                    push!(covered, isin(n, s))
                end

                if !any(covered)
                    push!(uncovered, n)
                end
            end
        end
    end

    return unique(uncovered)
end


function frequency(point::Tuple{Int, Int}, lim::Int)
    return lim * point[1] + point[2]
end


# Part 1
sensors = parse_sensors("day15.txt")
intervals = [impossible_x(2000000, sensor) for sensor in sensors]
println("Part 1: ", cardinality(intervals))

# Part 2
sensors = parse_sensors("day15.txt")
lim = 4000000
uncovered = not_covered(sensors, lim)
println("Part 2: ", frequency(uncovered[1], lim))
println()
