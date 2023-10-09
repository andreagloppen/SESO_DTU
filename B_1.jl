# Import necessary packages
using Pkg; Pkg.activate("env")
using JuMP
using HiGHS
using DataFrames
using Plots

include("Inputs_A_B.jl")

# Add the FCR reserve market! Add variable(s), change the objective and add constraint(s)

# Define the optimization model using a free solver
model = Model(HiGHS.Optimizer)

# Define production variables for every time-step
@variable(model, p_e[t in T, s in S] >= 0)  # Electrolyzer power schedulle per segment
@variable(model, h_e[t in T]  >= 0)         # Hydrogen schedulle
@variable(model, z[t in T, s in S], Bin)    # Segment tracker of electrolyzer piece-wise curve
@variable(model, p_DA[t in T] >= 0)         # Electrolyzer Day-ahead power schedulle

# Define the objective function that maximizes the profit of the electrolyzer
@objective(model, Max, sum(lambda_H2 * h_e[t] - lambda_DA[t] * p_DA[t]  for t in T ) )

# Define constraints
@constraint(model, [t in T, s in S], p_e[t,s] <= P_s_ub[s] * z[t,s],    base_name = "Maximum electrolyzer power per segment")
@constraint(model, [t in T, s in S], P_s_lb[s] * z[t,s] <= p_e[t,s],    base_name = "Minimum electrolyzer power per segment")
@constraint(model, [t in T], sum(z[t,s] for s in S) <= 1,               base_name = "At most one active segment per time")

@constraint(model, [t in T], sum(A[s] * p_e[t,s] + B[s]*z[t,s] for s in S) == h_e[t],   base_name = "Hydrogen production")
@constraint(model, [t in T], p_DA[t] == sum(p_e[t,s] for s in S),                       base_name = "Day-ahead schedule")

@constraint(model, sum(h_e[t] for t in T) >= H, base_name = "Hydrogen daily demand")


"""
# Solve the optimization problem
optimize!(model)

# Check the status of the optimization
status = termination_status(model)
if status == MOI.OPTIMAL
    println("Objective value: " , objective_value(model))

    # Gather the optimal decisions in a dataframe
    df = DataFrame(hydrogen = zeros(N), DA_power = zeros(N), FCR_reserve = zeros(N))
    for t in T
        df.hydrogen[t] = value(h_e[t])
        df.DA_power[t] = value(p_DA[t])
    end
    for i in I_FCR
        for j in T_i[i]
            df.FCR_reserve[j] = value(p_FCR[i])
        end
    end


    # PLot the result
    plt = plot(df.DA_power, labels="DA Power", linetype=:steppost, yaxis = "DA Power [MW]", xaxis = "Time")
    plot!(df.FCR_reserve, labels="FCR_reserve", linestyle=:dash, linetype=:steppost, color=:red, legend=:topright)
    title!("Electrolyzer Day-Ahead Schedule")
    display(plt)


    plt = plot(df.DA_power+df.FCR_reserve, linetype=:steppost, c = 2, label = false)
    plot!(T,df.DA_power, fillrange = df.DA_power+df.FCR_reserve, fillalpha = 0.35, c = 2, linetype=:steppost, label = "FCR reserve", legend = :topleft)
    
    plot!(df.DA_power-df.FCR_reserve, linetype=:steppost, c = 2, label = false)
    plot!(T,df.DA_power, fillrange = df.DA_power-df.FCR_reserve, fillalpha = 0.35, c = 2, linetype=:steppost, label = false, legend = :topleft)
    
    plot!(df.DA_power, labels="DA Power", linetype=:steppost, c = 1, yaxis = "DA Power [MW]", xaxis = "Time")

    display(plt)


else
    println("Optimization did not converge to an optimal solution.")
end

"""