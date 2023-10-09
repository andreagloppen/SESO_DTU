# Import necessary packages
using Pkg; Pkg.activate("env")
using JuMP
using HiGHS
using DataFrames
using Plots

include("Inputs_A_B.jl")

# Find the mistakes in the code! There are two

# Define the optimization model using a free solver
model = Model(HiGHS.Optimizer)

# Define production variables for every time-step
@variable(model, p_e[t in T, s in S] >= 0,) # Electrolyzer power schedulle per segment
@variable(model, h_e[t in T]  >= 0)         # Hydrogen schedulle
@variable(model, z[t in T, s in S], Bin)    # Segment tracker of electrolyzer piece-wise curve
@variable(model, p_DA[t in T] >= 0,)        # Electrolyzer Day-ahead power schedulle


# Define the objective function that maximizes the profit of the electrolyzer
@objective(model, Max, sum(lambda_H2 * h_e[t] - lambda_DA[t] * p_DA[t]  for t in T ))

# Define constraints
@constraint(model, [t in T, s in S], p_e[t,s] <= P_s_ub[s] * z[t,s],    base_name = "Maximum electrolyzer power per segment")
@constraint(model, [t in T, s in S], P_s_lb[s] * z[t,s] <= p_e[t,s],    base_name = "Minimum electrolyzer power per segment")
@constraint(model, [t in T], sum(z[t,s] for s in S) == 1,               base_name = "At most one active segment per time")

@constraint(model, [t in T, s in S], A[s] * p_e[t,s] + B[s]*z[t,s]  == h_e[t],   base_name = "Hydrogen production")
@constraint(model, [t in T], p_DA[t] == sum(p_e[t,s] for s in S),                       base_name = "Day-ahead schedule")

@constraint(model, sum(h_e[t] for t in T) >= H, base_name = "Hydrogen daily demand")


# Solve the optimization problem
optimize!(model)

# Check the status of the optimization
status = termination_status(model)
if status == MOI.OPTIMAL
    println("Objective value: " , objective_value(model))

    # Gather the optimal decisions in a dataframe
    df = DataFrame(hydrogen = zeros(N), power = zeros(N))
    for t in T
        df.hydrogen[t] = value(h_e[t])
        df.power[t] = value(sum(p_e[t,s] for s in S))
    end

    # PLot the result
    plt = plot(df.power, labels="Power", linetype=:steppost, yaxis = "Power [MW]", xaxis = "Time")
    #plot!(twinx(),df.hydrogen, labels="Hydrogen", linestyle=:dash, linetype=:steppost, color=:red, yaxis = "Hydrogen [kg]", legend=:topright)
    title!("Electrolyzer Day-Ahead Schedule")
    display(plt)


else
    println("Optimization did not converge to an optimal solution.")
end

