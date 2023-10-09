# Import necessary packages
using Pkg; Pkg.activate("env")
using JuMP
using HiGHS
using DataFrames
using Plots

include("Inputs_A_B.jl")

# Define the optimization model using a free solver
model = Model(HiGHS.Optimizer)

# Define production variables for every time-step
@variable(model,  p_e[t in T] >= 0)     # Electrolyzer power schedulle
@variable(model,  h_e[t in T]  >= 0)    # Hydrogen schedulle


# Define the objective function that maximizes the profit of the electrolyzer
@objective(model, Max, sum(h_e[t] * lambda_H2  - p_e[t] * lambda_DA[t]  for t in T ))

# Define the constraints as in the mathematical formulation
# First constraint is given:
@constraint(model, [t in T], p_e[t] <= P_e_max,       base_name = "Maximum electrolyzer power")




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