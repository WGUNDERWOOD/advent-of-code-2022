open("day01.txt") do file

    counter = 0
    totals = Int[]

    for l in eachline(file)
        if l != ""
            counter += parse(Int, l)
        else
            push!(totals, counter)
            counter = 0
        end
    end

    push!(totals, counter)
    display(maximum(totals))
    top_3_totals = sort(totals, rev=true)[1:3]
    display(sum(top_3_totals))
end
