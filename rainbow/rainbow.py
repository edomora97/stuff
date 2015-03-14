#!/usr/bin/env python

import math
import subprocess

def clamp(x, minimum, maximum):
    return max(minimum, min(x, maximum))
def gaussian (w, x):
	return (w**-0.5) * math.exp(-(x/2*w)**2)
def wl2rgb (wl, f = 0.02):
	mult = 255 / gaussian(f, 0)
	r = mult * gaussian(f, wl-660)
	g = mult * gaussian(f, wl-550)
	b = mult * gaussian(f, wl-460)

	r = clamp(r, 0, 255) / 255 * 9.9 + 0.1
	g = clamp(g, 0, 255) / 255 * 9.9 + 0.1
	b = clamp(b, 0, 255) / 255 * 9.9 + 0.1

	return [r,g,b]

minwl = 300.0
maxwl = 800.0
step = 0.3

wl = minwl
up = True

while True:
	rgb = wl2rgb(wl)
	subprocess.call(["xgamma",
		"-rgamma", str(rgb[0]),
		"-ggamma", str(rgb[1]),
		"-bgamma", str(rgb[2])])
	if up:
		wl=wl+step
	else:
		wl=wl-step
	if wl >= maxwl:
		up = False
	if wl <= minwl:
		up = True
