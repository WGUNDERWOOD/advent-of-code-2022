println("Day 25")


function snafu_to_decimal(snafu::String)

    n = length(snafu)
    rev_snafu = reverse(snafu)
    decimal = 0
    values = Dict('2' => 2, '1' => 1, '0' => 0, '-' => -1, '=' => -2)

    for i in 1:n
        s = rev_snafu[i]
        v = values[s]
        decimal += v * 5^(i-1)
    end

    return decimal
end


function decimal_to_snafu(decimal::Int)

    power = round(Int, log(abs(decimal)) / log(5), RoundUp) + 2
    snafu =  decimal_to_snafu(decimal, power)
    return lstrip(snafu, '0')
end


function decimal_to_snafu(decimal::Int, power::Int)

    values = Dict(2 => '2', 1 => '1', 0 => '0', -1 => '-', -2 => '=')

    if -2 <= decimal <= 2
        zs = join(["0" for _ in 1:power])
        return zs * string(values[decimal])

    else

        rems = Int[]

        for i in -2:2
            push!(rems, decimal - (i * 5^power))
        end

        best_i = argmin(abs.(rems))
        best_rem = rems[best_i]

        return values[best_i-3] * decimal_to_snafu(best_rem, power - 1)
    end
end


filepath = "day25.txt"
snafus = readlines(filepath)
decimal_sum = sum(snafu_to_decimal.(snafus))
snafu_sum = decimal_to_snafu(decimal_sum)
println("Part 1: ", snafu_sum)
println("Part 2: ", join(["★" for _ in 1:50]))
println()
