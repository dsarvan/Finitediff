#!/usr/bin/env julia
# File: fd1dn_1_1.jl
# Name: D.Saravanan
# Date: 11/10/2021

""" Simulation in free space """
# FDTD simulation of a pulse in free space after 100 steps.
# The pulse originated in the center and travels outward.

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
nsteps = 100

# FDTD loop
for time_step = 1:nsteps

    # calculate the Ex field
    ex[2:ke] = ex[2:ke] + 0.5 * (hy[1:ke-1] - hy[2:ke])

    # put a Gaussian pulse in the middle
    ex[kc] = exp(-0.5 * ((t0 - time_step) / spread)^2)

    # calculate the Hy field
    hy[1:ke-1] = hy[1:ke-1] + 0.5 * (ex[1:ke-1] - ex[2:ke])

end

fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle(raw"FDTD simulation of a pulse in free space after 100 time steps")
ax1.plot(ex, "k", lw = 1)
ax1.text(100, 0.5, "T = $nsteps", horizontalalignment = "center")
ax1.set(xlim = (0, 200), ylim = (-1.2, 1.2), ylabel = L"E$_x$")
ax1.set(xticks = 0:20:200, yticks = -1:1:1.2)
ax2.plot(hy, "k", lw = 1)
ax2.set(xlim = (0, 200), ylim = (-1.2, 1.2), xlabel = raw"FDTD cells", ylabel = L"H$_y$")
ax2.set(xticks = 0:20:200, yticks = -1:1:1.2)
plt.subplots_adjust(bottom = 0.2, hspace = 0.45)
plt.savefig("fd1dn_1_1.png")
