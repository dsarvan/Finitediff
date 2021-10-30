#!/usr/bin/env julia
# File: fd1d_1_1.jl
# Name: D.Saravanan
# Date: 11/10/2021

""" Simulation in free space """

import PyPlot
const plt = PyPlot

ke = 200
ex = zeros(ke)
hy = zeros(ke)

# Pulse parameters
kc = Int(ke/2)
t0 = 40
spread = 12
nsteps = 100

# FDTD loop
for time_step in 2:nsteps
    
    # calculate the Ex field
    for k in 2:ke
        ex[k] = ex[k] + 0.5 * (hy[k - 1] - hy[k])
        println(ex[k])
    end

    # put a Gaussian pulse in the middle
    ex[kc] = exp(-0.5 * ((t0 - time_step)/spread)^2)
    
    # calculate the Hy field
    for k in 2:(ke - 1)
        hy[k] = hy[k] + 0.5 * (ex[k] - ex[k + 1])
    end

end

#fig, (ax1, ax2) = plt.subplots(2)
##fig.subtitle(raw"FDTD simulation of a pulse in free space after 100 time steps")
#ax1.plot(ex, 'k', lw=1)
#ax2.plot(hy, 'k', lw=1)
#plt.subplots_adjust(bottom=0.2, hspace=0.45)
#plt.savefig("fd1d_1_1.png")
