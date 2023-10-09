
#######################################
#              Block A                #
#######################################

include("Inputs.jl")


lambda_DA = df.spotMeas[1:N]/7.7 # Day-ahead prices in EUR/MWh
P_W = df.windMeas[1:N] * C_W        # Wind in MWh

#######################################
#              Block B                #
#######################################

N_FCR = 4                   # Number of hours in 1 FCR block (there are 6 blocks per day)
I_FCR = 1:Integer(N/N_FCR)  # Range of FCR time slots

T_i = [T[(i-1) * N_FCR + 1:i * N_FCR] for i in I_FCR] # Split the full time range into one per FCR block


lambda_FCR = rand(0:30, Integer(N/N_FCR))  # FCR reserve prices in EUR/MW/h
lambda_mFRR_up = rand(0:10, N)             # mFRR up reserve prices in EUR/MW/h

