using Pkg; Pkg.activate("env") # Path to the enviornment folder "env"
using CSV

using Random
Random.seed!(1)

# Import data
df = DataFrame(CSV.File("Data/data.csv"))

# Define the number of timesteps in our modelling horizon and a corresponing range
N = 24
T = 1:N # Note that Julia is 1-indexed

# Define input parameters
lambda_H2 = 2 # Hydrogen price (fixed by bilateral constract) in EUR/kg
P_e_max = 10 # Electrolyzer capacity in MW
eta_H2 = 19 # Electrolyzer power to hydrogen efficiency in kg/MW
H = 30 # Daily hudrogen demand [kg]

P_e_min = 0.1 * P_e_max # Electrolyzer minimum load in MW

A = [19.37, 16.14]      # Production curve of electrolyzer
B = [-0.225, 0.857]
S = 1:length(A)

P_s_lb = [0.1, 0.3] * P_e_max # Lower bound of segment
P_s_ub = [0.3, 1]   * P_e_max # Upper bound of segment

C_W = 10
