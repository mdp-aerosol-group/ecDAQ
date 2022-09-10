using NumericIO
using InspectDR
using Colors

function time_series(yaxis)
	plot = InspectDR.transientplot(yaxis, title="")
	InspectDR.overwritefont!(plot.layout, fontname="Helvetica", fontscale=1.0)
	plot.layout[:enable_legend] = true
	plot.layout[:halloc_legend] = 130
	plot.layout[:halloc_left] = 50
	plot.layout[:enable_timestamp] = false
	plot.layout[:length_tickmajor] = 10
	plot.layout[:length_tickminor] = 6
	plot.layout[:format_xtick] = InspectDR.TickLabelStyle(UEXPONENT)
	plot.layout[:frame_data] =  InspectDR.AreaAttributes(
         line=InspectDR.line(style=:solid, color=RGBA(0,0,0,1), width=0.5))
	plot.layout[:line_gridmajor] = InspectDR.LineStyle(:solid, Float64(0.75), 
													   RGBA(0, 0, 0, 1))

	plot.xext = InspectDR.PExtents1D()
	plot.xext_full = InspectDR.PExtents1D(0, 30)

	a = plot.annotation
	a.xlabel = ""
	a.ylabels = [""]

	return plot
end

function block_series(yaxis)
	plot = InspectDR.transientplot(yaxis, title="")
	InspectDR.overwritefont!(plot.layout, fontname="Helvetica", fontscale=1.0)
	plot.layout[:enable_legend] = false
	plot.layout[:enable_timestamp] = false
	plot.layout[:length_tickmajor] = 10
	plot.layout[:length_tickminor] = 6
	plot.layout[:format_xtick] = InspectDR.TickLabelStyle(UEXPONENT)
	plot.layout[:frame_data] =  InspectDR.AreaAttributes(
         line=InspectDR.line(style=:solid, color=RGBA(0,0,0,1), width=0.5))
	plot.layout[:line_gridmajor] = InspectDR.LineStyle(:solid, Float64(0.75), 
													   RGBA(0, 0, 0, 1))

	plot.xext = InspectDR.PExtents1D()
	plot.xext_full = InspectDR.PExtents1D(0, 30)

	a = plot.annotation
	a.xlabel = ""
	a.ylabels = [""]

	return plot
end

plotDir = time_series(:lin)
mpPlotDir,gplotPlotDir = push_plot_to_gui!(plotDir, gui["RawDir"], wnd)
wfrm = add(plotDir, [0.0], [22.0], id="Dir (°)")
wfrm.line = line(color=black, width=1, style=:solid)

plotVel = time_series(:lin)
mpPlotVel,gplotPlotVel = push_plot_to_gui!(plotVel, gui["RawVel"], wnd)
wfrm = add(plotVel, [0.0], [22.0], id="vel (m/s)")
wfrm.line = line(color=black, width=1, style=:solid)

plotW = time_series(:lin)
mpPlotVel,gplotPlotW = push_plot_to_gui!(plotW, gui["RawW"], wnd)
wfrm = add(plotW, [0.0], [22.0], id="w (m/s)")
wfrm.line = line(color=black, width=1, style=:solid)

plotT = time_series(:lin)
mpPlotT,gplotPlotT = push_plot_to_gui!(plotT, gui["RawT"], wnd)
wfrm = add(plotT, [0.0], [22.0], id="T (°C)")
wfrm.line = line(color=black, width=1, style=:solid)

plotQ = time_series(:lin)
mpPlotQ,gplotPlotQ = push_plot_to_gui!(plotQ, gui["RawQ"], wnd)
wfrm = add(plotQ, [0.0], [22.0], id="RH (%)")
wfrm.line = line(color=black, width=1, style=:solid)

plotDiag1 = time_series(:lin)
mpPlotDiag1,gplotPlotDiag1 = push_plot_to_gui!(plotDiag1, gui["Diagnostic1"], wnd)
wfrm = add(plotDiag1, [0.0], [22.0], id="delta t")
wfrm.line = line(color=black, width=1, style=:solid)
graph = plotDiag1.strips[1]
graph.yext = InspectDR.PExtents1D() 
graph.yext_full = InspectDR.PExtents1D(90, 110)

plotLag1 = time_series(:lin)
mpPlotLag1,gplotPlotLag1 = push_plot_to_gui!(plotLag1, gui["Lag1"], wnd)
wfrm = add(plotLag1, [0.0], [0.0], id="w'CPC1C'")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotLag1, [0.0], [0.0], id="lag")
wfrm.line = line(color=red, width=2, style=:dash)
graph = plotLag1.strips[1]
graph.yext = InspectDR.PExtents1D() 
graph.yext_full = InspectDR.PExtents1D(0, 1)


plotLag2 = time_series(:lin)
mpPlotLag2,gplotPlotLag2 = push_plot_to_gui!(plotLag2, gui["Lag2"], wnd)
wfrm = add(plotLag2, [0.0], [0.0], id="w'CPC2C'")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotLag2, [0.0], [0.0], id="lag")
wfrm.line = line(color=red, width=2, style=:dash)
graph = plotLag2.strips[1]
graph.yext = InspectDR.PExtents1D() 
graph.yext_full = InspectDR.PExtents1D(0, 1)

plotLag3 = time_series(:lin)
mpPlotLag3,gplotPlotLag3 = push_plot_to_gui!(plotLag3, gui["Lag3"], wnd)
wfrm = add(plotLag3, [0.0], [0.0], id="w'CPC1S'")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotLag3, [0.0], [0.0], id="lag")
wfrm.line = line(color=red, width=2, style=:dash)
graph = plotLag3.strips[1]
graph.yext = InspectDR.PExtents1D() 
graph.yext_full = InspectDR.PExtents1D(0, 1)

plotLag4 = time_series(:lin)
mpPlotLag4,gplotPlotLag4 = push_plot_to_gui!(plotLag4, gui["Lag4"], wnd)
wfrm = add(plotLag4, [0.0], [0.0], id="w'CPC2S'")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotLag4, [0.0], [0.0], id="lag")
wfrm.line = line(color=red, width=2, style=:dash)
graph = plotLag4.strips[1]
graph.yext = InspectDR.PExtents1D() 
graph.yext_full = InspectDR.PExtents1D(0, 1)

plotLag5 = time_series(:lin)
mpPlotLag5,gplotPlotLag5 = push_plot_to_gui!(plotLag5, gui["Lag5"], wnd)
wfrm = add(plotLag5, [0.0], [0.0], id="w'POPS'")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotLag5, [0.0], [0.0], id="lag")
wfrm.line = line(color=red, width=2, style=:dash)
graph = plotLag5.strips[1]
graph.yext = InspectDR.PExtents1D() 
graph.yext_full = InspectDR.PExtents1D(0, 1)

plotCPC1 = time_series(:lin)
mpPlotCPC1,gplotPlotCPC1 = push_plot_to_gui!(plotCPC1, gui["RawCPC1"], wnd)
wfrm = add(plotCPC1, [0.0], [22.0], id="CPC1 (cm-3)")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotCPC1, [0.0], [22.0], id="CPC2 (cm-3)")
wfrm.line = line(color=red, width=1, style=:solid)
wfrm = add(plotCPC1, [0.0], [22.0], id="POPS (cm-3)")
wfrm.line = line(color=mblue, width=1, style=:solid)

plotXPXP1 = block_series(:lin)
mpPlotXPXP1,gplotPlotXPXP1 = push_plot_to_gui!(plotXPXP1, gui["xpxp1"], wnd)
wfrm = add(plotXPXP1, [0.0], [22.0], id="A")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotXPXP1, [0.0], [22.0], id="B")
wfrm.line = line(color=red, width=1, style=:solid)

plotXPXP2 = block_series(:lin)
mpPlotXPXP2,gplotPlotXPXP2 = push_plot_to_gui!(plotXPXP2, gui["xpxp2"], wnd)
wfrm = add(plotXPXP2, [0.0], [22.0], id="A")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotXPXP2, [0.0], [22.0], id="B")
wfrm.line = line(color=red, width=1, style=:solid)

plotXPXP3 = block_series(:lin)
mpPlotXPXP3,gplotPlotXPXP3 = push_plot_to_gui!(plotXPXP3, gui["xpxp3"], wnd)
wfrm = add(plotXPXP3, [0.0], [22.0], id="A")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotXPXP3, [0.0], [22.0], id="B")
wfrm.line = line(color=red, width=1, style=:solid)
plotXPXP3.xext = InspectDR.PExtents1D()
plotXPXP3.xext_full = InspectDR.PExtents1D(0, 24)

plotXPXP4 = block_series(:lin)
mpPlotXPXP4,gplotPlotXPXP4 = push_plot_to_gui!(plotXPXP4, gui["xpxp4"], wnd)
wfrm = add(plotXPXP4, [0.0], [22.0], id="A")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotXPXP4, [0.0], [22.0], id="B")
wfrm.line = line(color=red, width=1, style=:solid)
plotXPXP4.xext = InspectDR.PExtents1D()
plotXPXP4.xext_full = InspectDR.PExtents1D(0, 24)

plotPOPSSize = InspectDR.Plot2D(:log,:log, title="")
InspectDR.overwritefont!(plotPOPSSize.layout, fontname="Helvetica", fontscale=1.0)
plotPOPSSize.layout[:enable_legend] = false
plotPOPSSize.layout[:enable_timestamp] = false
plotPOPSSize.layout[:length_tickmajor] = 10
plotPOPSSize.layout[:length_tickminor] = 6
plotPOPSSize.layout[:format_xtick] = InspectDR.TickLabelStyle(UEXPONENT)
plotPOPSSize.layout[:frame_data] =  InspectDR.AreaAttributes(
       line=InspectDR.line(style=:solid, color=black, width=0.5))
plotPOPSSize.layout[:line_gridmajor] = InspectDR.LineStyle(:solid, 
											Float64(0.75), RGBA(0, 0, 0, 1))

plotPOPSSize.xext = InspectDR.PExtents1D()
plotPOPSSize.xext_full = InspectDR.PExtents1D(100, 2000)
mpPlotPOPSSize,gplotPOPSSize = push_plot_to_gui!(plotPOPSSize, gui["RawPOPSSize"], wnd)
wfrm = add(plotPOPSSize, [200,300,400,500,600,700,800,900,1200], [10,15.0,30,20,10,1.0, 0.1, 0.04, 0.005], id="A")
wfrm.line = line(color=black, width=1, style=:solid)

graph = plotPOPSSize.strips[1]
graph.grid = InspectDR.GridRect(vmajor=true, vminor=true, 
								hmajor=true, hminor=true)

a = plotPOPSSize.annotation
a.xlabel = ""
a.ylabels = ["dN/dlnD (cm-3)"]


plotSpectra1 = InspectDR.Plot2D(:log,:lin, title="")
InspectDR.overwritefont!(plotSpectra1.layout, fontname="Helvetica", fontscale=1.0)
plotSpectra1.layout[:enable_legend] = false
plotSpectra1.layout[:enable_timestamp] = false
plotSpectra1.layout[:length_tickmajor] = 10
plotSpectra1.layout[:length_tickminor] = 6
plotSpectra1.layout[:format_xtick] = InspectDR.TickLabelStyle(UEXPONENT)
plotSpectra1.layout[:frame_data] =  InspectDR.AreaAttributes(
       line=InspectDR.line(style=:solid, color=black, width=0.5))
plotSpectra1.layout[:line_gridmajor] = InspectDR.LineStyle(:solid, 
											Float64(0.75), RGBA(0, 0, 0, 1))

plotSpectra1.xext = InspectDR.PExtents1D()
plotSpectra1.xext_full = InspectDR.PExtents1D(0.0001, 5)

graph = plotSpectra1.strips[1]
graph.grid = InspectDR.GridRect(vmajor=true, vminor=true, 
								hmajor=true, hminor=true)

a = plotSpectra1.annotation
a.xlabel = "Frequency (Hz)"
a.ylabels = ["f*S(x)/var(x)"]

mpPlotSpectra1,gplotSpectra1 = push_plot_to_gui!(plotSpectra1, gui["spectra1"], wnd)
wfrm = add(plotSpectra1, [0.5,0.05], [12.0,100.0], id="A")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotSpectra1, [5,0.5,0.05], [1.5,8,100.0], id="A")
wfrm.line = line(color=red, width=1, style=:solid)


plotSpectra2 = InspectDR.Plot2D(:log,:lin, title="")
InspectDR.overwritefont!(plotSpectra2.layout, fontname="Helvetica", fontscale=1.0)
plotSpectra2.layout[:enable_legend] = false
plotSpectra2.layout[:enable_timestamp] = false
plotSpectra2.layout[:length_tickmajor] = 10
plotSpectra2.layout[:length_tickminor] = 6
plotSpectra2.layout[:format_xtick] = InspectDR.TickLabelStyle(UEXPONENT)
plotSpectra2.layout[:frame_data] =  InspectDR.AreaAttributes(
       line=InspectDR.line(style=:solid, color=black, width=0.5))
plotSpectra2.layout[:line_gridmajor] = InspectDR.LineStyle(:solid, 
											Float64(0.75), RGBA(0, 0, 0, 1))

plotSpectra2.xext = InspectDR.PExtents1D()
plotSpectra2.xext_full = InspectDR.PExtents1D(0.0001, 5)

graph = plotSpectra2.strips[1]
graph.grid = InspectDR.GridRect(vmajor=true, vminor=true, 
								hmajor=true, hminor=true)

a = plotSpectra2.annotation
a.xlabel = "Frequency (Hz)"
a.ylabels = ["f*Co(w,y)/cov(w,y)"]

mpPlotSpectra2,gplotSpectra2 = push_plot_to_gui!(plotSpectra2, gui["spectra2"], wnd)
wfrm = add(plotSpectra2, [0.5,0.05], [12.0,100.0], id="A")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotSpectra2, [5,0.5,0.05], [1.5,8,100.0], id="A")
wfrm.line = line(color=red, width=1, style=:solid)
