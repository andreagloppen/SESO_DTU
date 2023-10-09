# Import necessary packages
using JuMP
using HiGHS
using DataFrames
using Plots

include("Inputs_C.jl")

# Write the full model, start from model C1.




"""

# Check the status of the optimization
status = termination_status(model)
if status == MOI.OPTIMAL
    println("Optimal solution found. Objective value: " , objective_value(model))

    # Gather the optimal decisions in a dictionary

    dict = Dict{String, Dict{String, Vector{Float64}}}()

    for i in Omega
        scenario_name = "Scenario $i"
        
        dict[scenario_name] = 
        Dict(
            "Hydrogen" => zeros(N),
            "DA power" => zeros(N),
            "DA price" => lambda_DA[:,i]

        )
        for t in T
            dict[scenario_name]["Hydrogen"][t] = value(h_e[t,i])
            dict[scenario_name]["DA power"][t] = value(p_DA[t,i])
        end

    end



    # Initialize the new dictionary
    new_dict = Dict{Int, Dict{String, Vector{Float64}}}()

    # Loop over time steps
    for t in T
        # Create a dictionary for the current time step
        new_dict[t] = Dict{String, Dict{String, Vector{Float64}}}()
        

        da_power_value = zeros(length(Omega))
        da_price_value = zeros(length(Omega))
        # Loop over scenarios
        for i in 1:length(Omega)
            scenario_name = "Scenario $(Omega[i])"
            
            # Extract "Hydrogen", "DA power", and "DA price" values
            da_power_value[i] = dict[scenario_name]["DA power"][t]
            da_price_value[i] = dict[scenario_name]["DA price"][t]
            
            # Create a new dictionary for the current scenario and time step

        end

        sorted_index = sortperm(da_price_value, rev = false) # Sort enteries after INCREASING DA price

        da_power_value = da_power_value[sorted_index]
        da_power_value = [min(val, P_ely_max) for val in da_power_value]

        # Auxillary points for the shape of the curve
        #push!(da_power_value, P_ely_max)
        da_price_value = da_price_value[sorted_index]
        #push!(da_price_value, 0)

        new_dict[t] = Dict(
            "DA power" => da_power_value,
            "DA price" => da_price_value
        )


    
    end

    # Create J plots
    J = 4
    I = N/J # subplots per plot

    for j in 1:J
        plots_array = []

        for i in ((j-1)*I+1):(((j-1)*I+I))
            hour =  Int(i)
            p = plot(new_dict[i]["DA power"], new_dict[i]["DA price"], linetype=:steppre, xlabel = "Quantity [MWh]", ylabel = "Price [EUR/MWh]", xlims = (0,P_ely_max*1.1), label = "Hour $hour")
            push!(plots_array, p)
        end

        # Layout the subplots in a 4x6 grid (adjust the layout based on your preference)
        plt = plot(plots_array..., layout=(2, 3))

        # Display the combined plot
        display(plt)
    end

else
    println("Optimization did not converge to an optimal solution.")
end


"""