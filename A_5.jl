# Import necessary packages
using Pkg; Pkg.activate("env")
using JuMP
using HiGHS
using DataFrames
using Plots

include("Inputs_A_B.jl")

# Write up the full model, start from A3


"""
# Check the status of the optimization
status = termination_status(model)
if status == MOI.OPTIMAL
    println("Optimal solution found. Objective value: " , objective_value(model))

    # Gather the optimal decisions in a dataframe
    df = DataFrame(hydrogen = zeros(N) , DA_power = zeros(N))
    for t in T
        df.hydrogen[t] = value(h_e[t])
        df.DA_power[t] = value(p_DA[t])
    end

    # PLot the result
    plt = plot(df.DA_power, labels="DA Power sold", linetype=:steppost, yaxis = "Power [MW]", xaxis = "Time")
    plot!(twinx(),df.hydrogen, labels="Hydrogen produced", linestyle=:dash, linetype=:steppost, color=:red, yaxis = "Hydrogen [kg]", legend=:topright)
    title!("Hybrid-Power-Plant Day-Ahead Schedule")
    display(plt)


else
    println("Optimization did not converge to an optimal solution.")
end

"""