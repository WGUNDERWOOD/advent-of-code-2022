println("Day 4")

function parse_assignment(s::String)
    (s1, s2) = String.(split(s, "-"))
    s1_int = parse(Int, s1)
    s2_int = parse(Int, s2)
    return (s1_int, s2_int)
end


function split_assignments(s::String)
    (s1, s2) = String.(split(s, ","))
    return (s1, s2)
end


function is_subassignment(ass1::Tuple{Int,Int}, ass2::Tuple{Int,Int})

    sub1 = (ass1[1] >= ass2[1]) && (ass1[2] <= ass2[2])
    sub2 = (ass2[1] >= ass1[1]) && (ass2[2] <= ass1[2])
    return sub1 || sub2
end

function overlap(ass1::Tuple{Int,Int}, ass2::Tuple{Int,Int})

    ov1 = (ass1[1] <= ass2[1] <= ass1[2])
    ov2 = (ass2[1] <= ass1[1] <= ass2[2])
    return ov1 || ov2
end


open("day04.txt") do file
    pairs = collect(eachline(file))
    splits = split_assignments.(pairs)
    parsed = [parse_assignment.(s) for s in splits]
    subs = [is_subassignment(p[1], p[2]) for p in parsed]
    overlaps = [overlap(p[1], p[2]) for p in parsed]
    println("Part 1: ", sum(subs))
    println("Part 2: ", sum(overlaps))
end

println()
