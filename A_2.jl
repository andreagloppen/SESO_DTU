# Import necessary packages
using Pkg; Pkg.activate("env")
using JuMP
using HiGHS
using DataFrames
using Plots

include("Inputs_A_B.jl")


# Write up the full model, a good tip is to start from A1


"""
# Check the status of the optimization
status = termination_status(model)
if status == MOI.OPTIMAL
    println("Objective value: " , objective_value(model))

    # Gather the optimal decisions in a dataframe
    df = DataFrame(hydrogen = zeros(N), power = zeros(N))
    for t in T
        df.hydrogen[t] = value(h_e[t])
        df.power[t] = value(p_e[t])
    end

    # PLot the result
    plt = plot(df.power, labels="Electrolyzer", linetype=:steppost)
    xlabel!("Time")
    ylabel!("Power [MW]")
    title!("Day-Ahead Schedule")
    display(plt)

else
    println("Optimization did not converge to an optimal solution.")
end
"""