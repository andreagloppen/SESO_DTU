include("Inputs.jl")

include("C_2.jl")

accepted_p_DA = out_of_sample_bids(Omega, lambda_DA, p_DA)

model = Model(HiGHS.Optimizer)

# Define production variables for every time-step
@variable(model, p_e[t in T, s in S, w in Omega_prime] >= 0) # Electrolyzer power schedulle per segment
@variable(model, h_e[t in T, w in Omega_prime]  >= 0)         # Hydrogen schedulle
@variable(model, z[t in T, s in S, w in Omega_prime], Bin)    # Segment tracker of electrolyzer piece-wise curve
@variable(model, p_bal_up[t in T, w in Omega_prime])  # Up regulating power
@variable(model, h_slack[w in Omega_prime] >= 0)  # Not fulfilled demnd


# Define the objective function that maximizes the profit of the electrolyzer
@objective(model, Max, sum(1/length(Omega_prime) * sum(lambda_H2 * h_e[t,w] + lambda_DA[t,w] * accepted_p_DA[t,w] + lambda_bal_up[t,w] * p_bal_up[t,w] for t in T ) - 1000 * h_slack[w] for w in Omega_prime) ) 

# Define constraints
@constraint(model, [t in T, w in Omega_prime], P_W[t,w] + p_bal_up[t,w] == accepted_p_DA[t,w] + sum(p_e[t,s,w] for s in S))


@constraint(model, [t in T, s in S, w in Omega_prime], p_e[t,s,w] <= P_s_ub[s] * z[t,s,w])
@constraint(model, [t in T, s in S, w in Omega_prime], P_s_lb[s] * z[t,s,w] <= p_e[t,s,w])
@constraint(model, [t in T, w in Omega_prime], sum(z[t,s,w] for s in S) <= 1)

@constraint(model, [t in T, w in Omega_prime], h_e[t,w] == sum(A[s] * p_e[t,s,w] + B[s]*z[t,s,w] for s in S))


@constraint(model, [w in Omega_prime], sum(h_e[t,w] for t in T) >= H - h_slack[w])


# Solve the optimization problem
optimize!(model)


# Check the status of the optimization
status = termination_status(model)
if status == MOI.OPTIMAL
    println("Optimal solution found. Expected OOS value: " , objective_value(model))

else
    println("Optimization did not converge to an optimal solution.")
end


