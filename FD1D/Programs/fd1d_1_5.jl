#!/usr/bin/env julia
# File: fd1d_1_5.jl
# Name: D.Saravanan
# Date: 29/10/2021

""" Simulation of a sinusoidal wave hitting a lossy dielectric """

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
epsz = 8.854e-12    # vaccum permittivity (F/m)
epsilon = 4         # relative permittivity
sigma = 0.04        # conductivity (S/m)

ca = ones(ke)
cb = 0.5 * ones(ke)

eaf = dt * sigma / (2 * epsz * epsilon)
ca[100:end] .= (1 - eaf) / (1 + eaf)
cb[100:end] .= 0.5 / (epsilon * (1 + eaf))

nsteps = 500

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

end

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle(raw"FDTD simulation of a sinusoidal wave hitting a lossy dielectric")
ax1.plot(ex, "k", lw = 1)
ax1.plot((0.5 ./ cb .- 1) ./ 3, "k--", lw = 0.75)
ax1.text(50, 0.5, "T = $nsteps", horizontalalignment = "center")
ax1.text(170, 0.5, "Eps = $epsilon", horizontalalignment = "center")
ax1.text(170, -0.5, "Cond = $sigma", horizontalalignment = "center")
ax1.set(xlim = (0, 200), ylim = (-1.2, 1.2), ylabel = L"E$_x$")
ax1.set(xticks = 0:20:200, yticks = -1:1:1.2)
ax2.plot(hy, "k", lw = 1)
ax2.plot((0.5 ./ cb .- 1) ./ 3, "k--", lw = 0.75)
ax2.text(50, 0.5, "T = $nsteps", horizontalalignment = "center")
ax2.text(170, 0.5, "Eps = $epsilon", horizontalalignment = "center")
ax2.text(170, -0.5, "Cond = $sigma", horizontalalignment = "center")
ax2.set(xlim = (0, 200), ylim = (-1.2, 1.2), xlabel = raw"FDTD cells", ylabel = L"H$_y$")
ax2.set(xticks = 0:20:200, yticks = -1:1:1.2)
plt.subplots_adjust(bottom = 0.2, hspace = 0.45)
plt.savefig("fd1d_1_5.png")
