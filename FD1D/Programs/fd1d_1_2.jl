#!/usr/bin/env julia
# File: fd1d_1_2.jl
# Name: D.Saravanan
# Date: 19/10/2021
""" Simulation of a pulse with absorbing boundary conditions """

import PyPlot
const plt = PyPlot
plt.rc("text", usetex = "True")
plt.rc("pgf", texsystem = "pdflatex")
plt.rc("font", family = "serif", weight = "normal", size = 8)
plt.rc("axes", labelsize = 10, titlesize = 10)
plt.rc("figure", titlesize = 10)
using LaTeXStrings

ke = 202
ex = zeros(ke)
hy = zeros(ke)

# Pulse parameters
kc = round(Int64, ke / 2)
t0 = 40
spread = 12
nsteps = 250

boundary_low = [0.0, 0.0]
boundary_high = [0.0, 0.0]

# desired points for plotting
points = [
    Dict("num_steps" => 100, "data" => nothing, "label" => " "),
    Dict("num_steps" => 225, "data" => nothing, "label" => " "),
    Dict("num_steps" => 250, "data" => nothing, "label" => "FDTD cells"),
]

# FDTD loop
for time_step = 1:nsteps

    # calculate the Ex field
    for k = 2:ke
        ex[k] = ex[k] + 0.5 * (hy[k-1] - hy[k])
    end

    # put a Gaussian pulse in the middle
    ex[kc] = exp(-0.5 * ((t0 - time_step) / spread)^2)

    # absorbing boundary conditions
    ex[1] = popfirst!(boundary_low)
    push!(boundary_low, ex[2])
    ex[ke-1] = popfirst!(boundary_high)
    push!(boundary_high, ex[ke-2])

    # calculate the Hy field
    for k = 1:(ke-1)
        hy[k] = hy[k] + 0.5 * (ex[k] - ex[k+1])
    end

    # save data at certain points for plotting
    for plot_data in points
        if time_step == plot_data["num_steps"]
            plot_data["data"] = copy(ex)
        end
    end

end

fig = plt.figure(figsize = (8, 5.25))
fig.suptitle(raw"FDTD simulation with absorbing boundary conditions")


function plotting(ax, data, timestep, label)
    """plot of E field at a single time step"""
    ax.plot(data, "k", linewidth = 1)
    ax.set(xlim = (0, 200), ylim = (-0.2, 1.2), xlabel = "$label", ylabel = L"E$_x$")
    ax.set(xticks = 0:20:200, yticks = 0:1:1.2)
    ax.text(100, 0.5, "T = $timestep", horizontalalignment = "center")
end


for (subplot_num, plot_data) in enumerate(points)
    ax = fig.add_subplot(3, 1, subplot_num)
    plotting(ax, plot_data["data"], plot_data["num_steps"], plot_data["label"])
end

plt.tight_layout()
plt.savefig("fd1d_1_2.png")
