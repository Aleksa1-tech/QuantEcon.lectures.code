#=

Author: Shunsuke Hori

=#

"""
This holds the results for Harrison Kreps.  In particular, it
accepts two matrices Qa and Qb and compares the single belief,
optimistic belief, and pessimistic belief prices
"""
struct PriceHolder{TF<:AbstractFloat}
    qa::Matrix{TF}
    qb::Matrix{TF}
    qpess::Matrix{TF}
    qopt::Matrix{TF}
    dividend_payoff::Vector{TF}
    qaprice::Vector{TF}
    qbprice::Vector{TF}
    qpessprice::Vector{TF}
    qoptprice::Vector{TF}
    optimisticprice::Vector{TF}
    pessimisticprice::Vector{TF}
    phat_a::Vector{TF}
    phat_b::Vector{TF}
end

function PriceHolder{TF<:AbstractFloat}(qa::Matrix,
                                        qb::Matrix,
                                        dividend_payoff::Vector;
                                        beta::TF=.75,
                                        max_iters::Integer=10000,
                                        tolerance::TF=1e-16)

    # Create the Pessimistic and Optimistic Beliefs
    qpess = Array{TF}(2, 2)
    qpess[1, :] = ifelse(qa[1, 2] < qb[1, 2], qa[1, :], qb[1, :])
    qpess[2, :] = ifelse(qa[2, 2] < qb[2, 2], qa[2, :], qb[2, :])
    qopt = Array{TF}(2, 2)
    qopt[1, :] = ifelse(qa[1, 2] > qb[1, 2], qa[1, :], qb[1, :])
    qopt[2, :] = ifelse(qa[2, 2] > qb[2, 2], qa[2, :], qb[2, :])

    # Price everything
    p_singlebelief, p_optimistic, phat_a, phat_b, p_pessimistic=
        create_prices(qa, qb, qpess, qopt, dividend_payoff,
                                    beta,max_iters,tolerance)

    qaprice = p_singlebelief[1]
    qbprice = p_singlebelief[2]
    qpessprice = p_singlebelief[3]
    qoptprice = p_singlebelief[4]

    return PriceHolder(qa,
                        qb,
                        qpess,
                        qopt,
                        dividend_payoff,
                        qaprice,
                        qbprice,
                        qpessprice,
                        qoptprice,
                        p_optimistic,
                        p_pessimistic,
                        phat_a,
                        phat_b)
end

"""
Computes prices under all belief systems
"""
function create_prices(qa::Matrix, qb::Matrix, qpess::Matrix, qopt::Matrix,
                       dividend_payoff::Vector, bet::AbstractFloat, 
                       max_iters::Integer, tolerance::AbstractFloat)
    transitionmatrix = [qa, qb, qpess, qopt]
    # Single Belief Prices
    p_singlebelief = [price_singlebeliefs(q, dividend_payoff, beta=bet)
                         for q in transitionmatrix]

    # Compute Optimistic and Pessimistic beliefs
    p_optimistic, phat_a, phat_b =
        price_optimisticbeliefs([qa, qb], dividend_payoff,
                    beta=bet, max_iter=max_iters, tol=tolerance)
    p_pessimistic =
        price_pessimisticbeliefs([qa, qb], dividend_payoff,
                    beta=bet, max_iter=max_iters, tol=tolerance)

    return p_singlebelief, p_optimistic, phat_a, phat_b, p_pessimistic
end



function print_prices(ph::PriceHolder)
    qaprice, qbprice, qpessprice, qoptprice =
        ph.qaprice, ph.qbprice, ph.qpessprice, ph.qoptprice
    optimisticprice, pessimisticprice =
        ph.optimisticprice, ph.pessimisticprice
    phata, phatb = ph.phat_a, ph.phat_b
    println("The Single Belief Price Vectors are:")
    println(" P(Qa) = $(qaprice)\n P(Qb) = $(qbprice)\n P(Qopt) = $(qoptprice)\n P(Qpess) = $(qpessprice)\n")
    println("The Optimistic Belief Price Vector is:")
    println(" P(Optimistic) = $(optimisticprice)\n Phat(a) = $(phata)\n Phat(b) = $(phatb)\n")
    println("The Pessimistic Belief Price Vector is:")
    println(" P(Pessimistic) = $(pessimisticprice)")
end

ph=PriceHolder(qa, qb, [0.0, 1.0], beta=0.75)

print_prices(ph)
