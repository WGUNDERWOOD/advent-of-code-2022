outcome_1 = Dict(
    "A X" => 1 + 3,
    "A Y" => 2 + 6,
    "A Z" => 3 + 0,
    "B X" => 1 + 0,
    "B Y" => 2 + 3,
    "B Z" => 3 + 6,
    "C X" => 1 + 6,
    "C Y" => 2 + 0,
    "C Z" => 3 + 3,
)

outcome_2 = Dict(
    "A X" => 3 + 0,
    "A Y" => 1 + 3,
    "A Z" => 2 + 6,
    "B X" => 1 + 0,
    "B Y" => 2 + 3,
    "B Z" => 3 + 6,
    "C X" => 2 + 0,
    "C Y" => 3 + 3,
    "C Z" => 1 + 6,
)

open("day02.txt") do file
    score_1 = sum(outcome_1[l] for l in eachline(file))
    println(score_1)
end

open("day02.txt") do file
    score_2 = sum(outcome_2[l] for l in eachline(file))
    println(score_2)
end
