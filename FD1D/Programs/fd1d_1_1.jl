#!/usr/bin/env julia
# File: fd1d_1_1.jl
# Name: D.Saravanan
# Date: 11/10/2021

""" Simulation in free space """

import PyPlot
const plt = PyPlot
plt.rc("text", usetex = "True")
plt.rc("pgf", texsystem = "pdflatex")
plt.rc("font", family = "serif", weight = "normal", size = 8)
plt.rc("axes", labelsize = 10, titlesize = 10)
plt.rc("figure", titlesize = 10)
using LaTeXStrings

ke = 201
ex = zeros(ke)
hy = zeros(ke)

# Pulse parameters
kc = round(Int64, ke / 2)
t0 = 40
spread = 12
nsteps = 100

# FDTD loop
for time_step = 1:nsteps

    # calculate the Ex field
    for k = 2:ke
        ex[k] = ex[k] + 0.5 * (hy[k-1] - hy[k])
    end

    # put a Gaussian pulse in the middle
    ex[kc] = exp(-0.5 * ((t0 - time_step) / spread)^2)

    # calculate the Hy field
    for k = 1:(ke-2)
        hy[k] = hy[k] + 0.5 * (ex[k] - ex[k+1])
    end

end

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle(raw"FDTD simulation of a pulse in free space after 100 time steps")
ax1.plot(ex, "k", lw = 1)
ax1.text(100, 0.5, "T = $nsteps", horizontalalignment = "center")
ax1.set(xlim = (0, 200), ylim = (-1.2, 1.2), ylabel = L"E$_x$")
ax1.set(xticks = 0:20:200, yticks = -1:1:1.2)
ax2.plot(hy, "k", lw = 1)
ax2.set(xlim = (0, 200), ylim = (-1.2, 1.2), xlabel = raw"FDTD calls", ylabel = L"H$_y$")
ax2.set(xticks = 0:20:200, yticks = -1:1:1.2)
plt.subplots_adjust(bottom = 0.2, hspace = 0.45)
plt.savefig("fd1d_1_1.png")
