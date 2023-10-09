#######################################
#              Block C                #
#######################################
using Random
using StatsBase
include("Inputs.jl")

Random.seed!(1)


all_scenarios = 5 # Make length of the dataset
Omega_all = collect(1:all_scenarios)
lambda_DA = rand(0:100, (N, all_scenarios))
P_W = rand(0:C_W,(N, all_scenarios))
lambda_bal_up = lambda_DA * 0.9


# Select in-sample scenatios
IS = 2 # Number of in sample scenarios
Omega = sample(Omega_all, IS, replace=false) # Randomly select in-sample scenarios

# The OOS samples are those not icluded in the decision making process
Omega_prime = setdiff(Omega_all, Omega)




# Function for calculating the accepted bids upon DA price realization

function out_of_sample_bids(Omega, lambda_DA, p_DA)
    # Returns the accepted bid from the bidding curve in ALL scenarios
    accepted_p_DA = zeros(N,all_scenarios)

    for t in T
        for i in Omega_all
            temp = zeros(length(Omega))  
            for j in 1:length(Omega)
                # Check if realized prize is higher than the bid price
                if lambda_DA[t,i] >= lambda_DA[t,Omega[j]]
                    temp[j] = value(p_DA[t,Omega[j]]) # Temporary store the value of p_DA if realized DA price is higher than bid
                end
            end
            # The final accepted bid quantity is the maxmimum of the bids accepted on the p-q curve
            accepted_p_DA[t,i] = maximum(temp)

        end
    end
    return accepted_p_DA
end

