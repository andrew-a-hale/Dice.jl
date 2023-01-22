module Exploding

using Distributions
using Printf
Dice = DiscreteUniform(1, 6)

function game(req_successes, dice, threshold)
    successes = 0
    while dice > 0
        roll = rand(Dice)
        if roll < 6
            dice -= 1
        end
        if roll >= threshold
            successes += 1
        end
        if successes >= req_successes
            break
        end
    end
    successes >= req_successes
end

function expected_success(dice, threshold, exploding)
    if exploding
        round((6 - threshold + 1) / 6 * 6 / 5 * dice, digits=2)
    else
        round((6 - threshold + 1) / 6 * dice, digits=2)
    end
end

function simulate(N, s, d, t)
    n = 0
    for i ∈ 1:N
        n += game(s, d, t)
    end

    round(n / N, digits=4) * 100
end

function calculate(s, d, t)
    prob = (6 - t + 1) / 6
    dist = Binomial(d, prob)
    (ccdf(dist, s) + pdf(dist, s)) * 100
end

function grid(N, t, e)
    if e 
        string = @sprintf "grid -- success minimum value=%i exploding=%i method=monte carlo simulation size=%i\n" t e N
    else 
        string = @sprintf "grid -- success minimum value=%i exploding=%i method=exact calculation\n" t e
    end

    for s ∈ 1:10
        for d ∈ 1:9
            if (s < 10)
                if e
                    string *= @sprintf "%6.2f%% " simulate(N, s, d, t)
                else
                    string *= @sprintf "%6.2f%% " calculate(s, d, t)
                end
            else
                string *= @sprintf "%6.2f  " expected_success(d, t, e)
            end
        end
        string *= "\n"
    end
    string *= "\n"
    string
end

function write_to_file()
    filename = "README.md"
    rm(filename, force=true)
    N = 10_000
    for e ∈ [false, true]
        for t ∈ 3:5
            open(filename, "a") do f
                @time write(f, grid(N, t, e))
            end
        end
    end
end

end