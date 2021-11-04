#!/usr/bin/env julia
# File: fd1d_1_4.jl
# Name: D.Saravanan
# Date: 22/10/2021

""" Simulation of a propagating sinusoidal wave of 700 MHz
striking a medium with a relative dielectric constant of 4 """

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

dx = 0.01             # Cell size 
dt = dx / 6e8         # Time step size
freq = 700e6          # Frequency 700 MHz

boundary_low = [0.0, 0.0]
boundary_high = [0.0, 0.0]

# Create Dielectric Profile
epsilon = 4
cb = ones(ke)
cb = 0.5 * cb
cb[100:end] .= 0.5 / epsilon

nsteps = 425

# desired points for plotting
points = [
    Dict("num_steps" => 150, "data" => nothing, "label" => " "),
    Dict("num_steps" => 425, "data" => nothing, "label" => "FDTD cells"),
]

# FDTD loop
for time_step = 1:nsteps

    # calculate the Ex field
    for k = 2:ke
        ex[k] = ex[k] + cb[k] * (hy[k-1] - hy[k])
    end

    # put a Gaussian pulse in the middle
    ex[6] = ex[6] + sin(2 * pi * freq * dt * time_step)

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
fig.suptitle(raw"FDTD simulation of a sinusoidal hitting a dielectric medium")


function plotting(ax, data, timestep, label)
    """plot of E field at a single time step"""
    ax.plot(data, "k", linewidth = 1)
    ax.plot((0.5 ./ cb .- 1) ./ 3, "k--", linewidth = 0.75)
    ax.set(xlim = (0, 200), ylim = (-0.2, 1.2), xlabel = "$label", ylabel = L"E$_x$")
    ax.set(xticks = 0:20:200, yticks = -1:1:1.2)
    ax.text(50, 0.5, "T = $timestep", horizontalalignment = "center")
    ax.text(170, 0.5, "Eps = $epsilon", horizontalalignment = "center")
end


for (subplot_num, plot_data) in enumerate(points)
    ax = fig.add_subplot(2, 1, subplot_num)
    plotting(ax, plot_data["data"], plot_data["num_steps"], plot_data["label"])
end

plt.subplots_adjust(bottom = 0.2, hspace = 0.45)
plt.savefig("fd1d_1_4.png")
