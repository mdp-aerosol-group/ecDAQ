
# Connect dropdown menus with callback functions...
gSelect1= gui["xpxp1G1"]
signal_connect(gSelect1, "changed") do widget, others...
	update_turbulence()
end

gSelect2= gui["xpxp1G2"]
signal_connect(gSelect2, "changed") do widget, others...
	update_turbulence()
end

gSelect3= gui["xpxp2G1"]
signal_connect(gSelect3, "changed") do widget, others...
	update_turbulence()
end

gSelect4= gui["xpxp2G2"]
signal_connect(gSelect4, "changed") do widget, others...
	update_turbulence()
end


gSelect1a= gui["xpxp3G1"]
signal_connect(gSelect1a, "changed") do widget, others...
	update_EC()
end

gSelect2a= gui["xpxp3G2"]
signal_connect(gSelect2a, "changed") do widget, others...
	update_EC()
end

gSelect3a= gui["xpxp4G1"]
signal_connect(gSelect3a, "changed") do widget, others...
	update_EC()
end

gSelect4a= gui["xpxp4G2"]
signal_connect(gSelect4a, "changed") do widget, others...
	update_EC()
end

gSelect5= gui["spectraLeft"]
signal_connect(gSelect5, "changed") do widget, others...
	update_spectra()
end

gSelect6= gui["spectraRight"]
signal_connect(gSelect6, "changed") do widget, others...
	update_spectra()
end

gSelect7= gui["coSpectraLeft"]
signal_connect(gSelect7, "changed") do widget, others...
	update_spectra()
end

gSelect8= gui["coSpectraRight"]
signal_connect(gSelect8, "changed") do widget, others...
	update_spectra()
end

button= gui["ComputeLags"]
signal_connect(button, "clicked") do widget, others...
	compute_lags(-5:0.1:5)
end

sbox1= gui["Lagt1"]
ids = signal_connect(sbox1, "value-changed") do widget, others...
	x = get_gtk_property(sbox1, "value", Float64)
	push!(δtCPC1C, x)
end

sbox2= gui["Lagt2"]
ids = signal_connect(sbox2, "value-changed") do widget, others...
	x = get_gtk_property(sbox2, "value", Float64)
	push!(δtCPC2C, x)
end

sbox3= gui["Lagt3"]
ids = signal_connect(sbox3, "value-changed") do widget, others...
	x = get_gtk_property(sbox3, "value", Float64)
	push!(δtCPC1S, x)
end

sbox4= gui["Lagt4"]
ids = signal_connect(sbox4, "value-changed") do widget, others...
	x = get_gtk_property(sbox4, "value", Float64)
	push!(δtCPC2S, x)
end

sbox5= gui["Lagt5"]
ids = signal_connect(sbox5, "value-changed") do widget, others...
	x = get_gtk_property(sbox5, "value", Float64)
	push!(δtPOPS, x)
end
