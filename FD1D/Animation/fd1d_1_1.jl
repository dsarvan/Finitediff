#!/usr/bin/env julia
# File: fd1d_1_1.jl
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
using PyCall
@pyimport matplotlib.animation as animation

ke = 202
ex = zeros(ke)
hy = zeros(ke)

# Pulse parameters
kc = round(Int64, ke / 2)
t0 = 40
spread = 12
nsteps = 300

# define the meta data for the movie
fwriter = animation.writers["ffmpeg"]
data = Dict("title" => "Simulation in free space")
writer = fwriter(fps=15, metadata=data)

# draw an empty plot, but preset the plot x- and y- limits
fig, (ax1, ax2) = plt.subplots(2)
fig.suptitle(raw"FDTD simulation of a pulse in free space")
(line1,) = ax1.plot(ex, "k", lw=1)
(line2,) = ax2.plot(hy, "k", lw=1)
time_text = ax1.text(0.02, 0.90, "", transform=ax1.transAxes)
ax1.set(xlim=(0, 200), ylim=(-1.2, 1.2), ylabel=L"$E_x$")
ax1.set(xticks = 0:20:200, yticks = -1:1:1.2)
ax2.set(xlim=(0, 200), ylim=(-1.2, 1.2), xlabel=raw"FDTD cells", ylabel=L"$H_y$")
ax2.set(xticks = 0:20:200, yticks = -1:1:1.2)

# FDTD loop
with writer.saving(fig, "fd1d_1_1.mp4", 100)
    for time_step = 1:nsteps

        # calculate the Ex field
        for k = 2:ke
            ex[k] = ex[k] + 0.5 * (hy[k-1] - hy[k])
        end

        # put a Gaussian pulse in the middle
        ex[kc] = exp(-0.5 * ((t0 - time_step) / spread)^2)

        # calculate the Hy field
        for k = 1:(ke-1)
            hy[k] = hy[k] + 0.5 * (ex[k] - ex[k+1])
        end
        
        line1.set_ydata(ex)
        time_text.set_text("T = {}".format(time_step))
        line2.set_ydata(hy)
        writer.grab_frame()

    end

end
