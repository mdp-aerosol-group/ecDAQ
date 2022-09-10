function update_oneHz()
    frame = @fetchfrom 2 DataAcquisitionLoops.RS232dataStream.value
    set_gtk_property!(gui["OneHzTime"], :text, Dates.format((frame.t)[1], "HH:MM:SS.s"))
    set_gtk_property!(gui["CPC1Serial"], :text, @sprintf("%.1f", (frame.CPC1)[1]))
    set_gtk_property!(gui["CPC2Serial"], :text, @sprintf("%.1f", (frame.CPC2)[1]))
    if isless((frame.POPS)[1], missing)
        set_gtk_property!(gui["POPSSerial"], :text, @sprintf("%.1f", (frame.POPS)[1]))
    else
        set_gtk_property!(gui["POPSSerial"], :text, @sprintf("missing"))
    end

    dstr = @fetchfrom 2 DataAcquisitionLoops.datestr
    HM = @fetchfrom 2 DataAcquisitionLoops.HHMM
    push!(datestr, dstr.value)
    push!(HHMM, HM.value)
end

function update_tenHz()
    frame = @fetchfrom 2 DataAcquisitionLoops.LJdataStream.value
    set_gtk_property!(gui["TenHzTime"], :text, Dates.format((frame.t)[1], "HH:MM:SS.s"))
    set_gtk_property!(gui["AverageU"], :text, @sprintf("%.2f", (frame.u)[1]))
    set_gtk_property!(gui["AverageV"], :text, @sprintf("%.2f", (frame.v)[1]))
    set_gtk_property!(gui["AverageW"], :text, @sprintf("%.2f", (frame.w)[1]))
    set_gtk_property!(gui["AverageVel"], :text, @sprintf("%.1f", (frame.vel)[1]))
    set_gtk_property!(gui["AverageDir"], :text, @sprintf("%i", (frame.dir)[1]))
    set_gtk_property!(gui["AverageT"], :text, @sprintf("%.1f", (frame.T)[1]))
    set_gtk_property!(gui["Tlj"], :text, @sprintf("%.1f", (frame.Tlj)[1]))
    set_gtk_property!(gui["Trot"], :text, @sprintf("%.1f", (frame.Trot)[1]))
    set_gtk_property!(gui["AverageRH"], :text, @sprintf("%.1f", (frame.RHrot)[1]))
    set_gtk_property!(gui["CPC1Count"], :text, @sprintf("%.1f", (frame.CPC1)[1]))
    set_gtk_property!(gui["CPC2Count"], :text, @sprintf("%.1f", (frame.CPC2)[1]))
end

function update_EC()
    t1 = t1HzInt.value
    x = (t1HzInt.value .- t1HzInt.value[1]) ./ 1000 / 60
    t1 = t1[20:end-20]
    x = x[20:end-20]
    function yp1yp2(extp1, extp2)
        yp1 = PowerSpectra.detrendLinear(x, extp1.value(t1))
        yp2 = PowerSpectra.detrendLinear(x, extp2.value(t1))
        yp1, yp2
    end

    t = now()
    up, vp = yp1yp2(extpU, extpV)
    wp, Tp = yp1yp2(extpW, extpW)
    TKE = 0.5 * (mean(up .* up) + mean(vp .* vp) + mean(wp .* wp))
    ustar = sqrt(mean(up .* wp)^2.0 + mean(vp .* wp)^2.0)
    k = 0.4   # von Karman
    z = 6.0   # measurement height
    g = 9.81  # gravity
    theta = (extpT.value(t1) .+ 273.15)
    zoL = -k * z * g * mean(wp .* Tp) / (mean(theta) * ustar^3.0)
    yp1, yp2 = yp1yp2(extpW, extpT)
    wT = mean(yp1 .* yp2)
    yp1, yp2 = yp1yp2(extpW, extpQ)
    wq = mean(yp1 .* yp2)
    yp1, yp2 = yp1yp2(extpW, extpCPC1C)
    wc1c = mean(yp1 .* yp2)
    yp1, yp2 = yp1yp2(extpW, extpCPC2C)
    wc2c = mean(yp1 .* yp2)
    yp1, yp2 = yp1yp2(extpW, extpUFC)
    wc12c = mean(yp1 .* yp2)
    yp1, yp2 = yp1yp2(extpW, extpCPC1S)
    wc1s = mean(yp1 .* yp2)
    yp1, yp2 = yp1yp2(extpW, extpCPC2S)
    wc2s = mean(yp1 .* yp2)
    yp1, yp2 = yp1yp2(extpW, extpUFS)
    wc12s = mean(yp1 .* yp2)
    yp1, yp2 = yp1yp2(extpW, extpPOPS)
    wc3s = mean(yp1 .* yp2)

    t123, Nt123, POPSDistribution = read_pops_file()
    ii = POPSDistribution .> 0.0
    addseries!(
        DpPOPS[ii],
        POPSDistribution[ii] ./ dlnDpPOPS[ii],
        plotPOPSSize,
        gplotPOPSSize,
        1,
        false,
        true,
    )


    df = DataFrame(
        t = t,
        tint = Dates.value(t),
        TKE = TKE,
        ustar = ustar,
        zoL = zoL,
        wT = wT,
        wq = wq,
        wc1c = wc1c,
        wc2c = wc2c,
        wc12c = wc12c,
        wc1s = wc1s,
        wc2s = wc2s,
        wc12s = wc12s,
        wc3s = wc3s,
        POPSdistribution = [POPSDistribution],
    )
    push!(ECdataStream, df)
    ECdataStream.value |> CSV.write(ECdataFilename.value, append = true)

    push!(ECBuffers.value.t, t)
    push!(ECBuffers.value.TKE, TKE)
    push!(ECBuffers.value.ustar, ustar)
    push!(ECBuffers.value.zoL, zoL)
    push!(ECBuffers.value.wT, wT)
    push!(ECBuffers.value.wq, wq)
    push!(ECBuffers.value.wc1c, wc1c)
    push!(ECBuffers.value.wc2c, wc2c)
    push!(ECBuffers.value.wc12c, wc12c)
    push!(ECBuffers.value.wc1s, wc1s)
    push!(ECBuffers.value.wc2s, wc2s)
    push!(ECBuffers.value.wc12s, wc12s)
    push!(ECBuffers.value.wc3s, wc3s)
    push!(ECBuffers.value.POPSDistribution, POPSDistribution)

    function updateXPXP3a(x, y)
        set_gtk_property!(gui["xpxp3FieldG1"], :text, @sprintf("%.2f", y[end]))
        addseries!(x, y, plotXPXP3, gplotPlotXPXP3, 1, false, true)
    end

    function updateXPXP3b(x, y)
        set_gtk_property!(gui["xpxp3FieldG2"], :text, @sprintf("%.2f", y[end]))
        addseries!(x, y, plotXPXP3, gplotPlotXPXP3, 2, false, true)
    end

    function updateXPXP4a(x, y)
        set_gtk_property!(gui["xpxp4FieldG1"], :text, @sprintf("%.2f", y[end]))
        addseries!(x, y, plotXPXP4, gplotPlotXPXP4, 1, false, true)
    end

    function updateXPXP4b(x, y)
        set_gtk_property!(gui["xpxp4FieldG2"], :text, @sprintf("%.2f", y[end]))
        addseries!(x, y, plotXPXP4, gplotPlotXPXP4, 2, false, true)
    end

    t2 = Dates.value.(ECBuffers.value.t .- DateTime(today())) ./ 1000.0 / 60.0 ./ 60.0
    function parse_xpxp(id)
        (id == "TKE") && (y = ECBuffers.value.TKE)
        (id == "ustar") && (y = ECBuffers.value.ustar)
        (id == "zoL") && (y = ECBuffers.value.zoL)
        (id == "wpTp") && (y = ECBuffers.value.wT)
        (id == "wpqp") && (y = ECBuffers.value.wq)
        (id == "wpc1cp") && (y = ECBuffers.value.wc1c)
        (id == "wpc2cp") && (y = ECBuffers.value.wc2c)
        (id == "wpc1cc2cp") && (y = ECBuffers.value.wc12c)
        (id == "wpc1sp") && (y = ECBuffers.value.wc1s)
        (id == "wpc2sp") && (y = ECBuffers.value.wc2s)
        (id == "wpc1sc2sp") && (y = ECBuffers.value.wc12s)
        (id == "wpc3p") && (y = ECBuffers.value.wc3s)
        y = convert(Array{Float64,1}, y)
        ii = isfinite.(y)
        t2[ii], y[ii]
    end

    xpxpA = get_gtk_property(gui["xpxp3G1"], "active-id", String)
    x1, y1 = parse_xpxp(xpxpA)
    updateXPXP3a(x1, y1)
    xpxpB = get_gtk_property(gui["xpxp3G2"], "active-id", String)
    x2, y2 = parse_xpxp(xpxpB)
    updateXPXP3b(x2, y2)

    xpxpC = get_gtk_property(gui["xpxp4G1"], "active-id", String)
    x3, y3 = parse_xpxp(xpxpC)
    updateXPXP4a(x3, y3)
    xpxpD = get_gtk_property(gui["xpxp4G2"], "active-id", String)
    x4, y4 = parse_xpxp(xpxpD)
    updateXPXP4b(x4, y4)
end

function update_turbulence()
    t1 = t1HzInt.value
    x = (t1HzInt.value .- t1HzInt.value[1]) ./ 1000 / 60
    t1 = t1[10:end-10]
    x = x[10:end-10]
    function yp1yp2(extp1, extp2)
        yp1 = PowerSpectra.detrendLinear(x, extp1.value(t1))
        yp2 = PowerSpectra.detrendLinear(x, extp2.value(t1))
        yp1, yp2
    end

    function updateXPXP1(yp1, yp2, yp3, yp4, plot, gplot)
        set_gtk_property!(gui["xpxp1FieldG1"], :text, @sprintf("%.2f", mean(yp1 .* yp2)))
        set_gtk_property!(gui["xpxp1FieldG2"], :text, @sprintf("%.2f", mean(yp3 .* yp4)))
        addseries!(x, yp1 .* yp2, plot, gplot, 1, false, true)
        addseries!(x, yp3 .* yp4, plot, gplot, 2, false, true)
    end

    function updateXPXP2(yp1, yp2, yp3, yp4, plot, gplot)
        set_gtk_property!(gui["xpxp2FieldG1"], :text, @sprintf("%.2f", mean(yp1 .* yp2)))
        set_gtk_property!(gui["xpxp2FieldG2"], :text, @sprintf("%.2f", mean(yp3 .* yp4)))
        addseries!(x, yp1 .* yp2, plot, gplot, 1, false, true)
        addseries!(x, yp3 .* yp4, plot, gplot, 2, false, true)
    end

    function parse_xpxp(id)
        (id == "upup") && ((yp1, yp2) = yp1yp2(extpU, extpU))
        (id == "vpvp") && ((yp1, yp2) = yp1yp2(extpV, extpV))
        (id == "wpwp") && ((yp1, yp2) = yp1yp2(extpW, extpW))
        (id == "wpTp") && ((yp1, yp2) = yp1yp2(extpW, extpT))
        (id == "wpqp") && ((yp1, yp2) = yp1yp2(extpW, extpQ))
        (id == "wpc1cp") && ((yp1, yp2) = yp1yp2(extpW, extpCPC1C))
        (id == "wpc2cp") && ((yp1, yp2) = yp1yp2(extpW, extpCPC2C))
        (id == "wpc1cc2cp") && ((yp1, yp2) = yp1yp2(extpW, extpUFC))
        (id == "wpc1sp") && ((yp1, yp2) = yp1yp2(extpW, extpCPC1S))
        (id == "wpc2sp") && ((yp1, yp2) = yp1yp2(extpW, extpCPC2S))
        (id == "wpc1sc2sp") && ((yp1, yp2) = yp1yp2(extpW, extpUFS))
        (id == "wpc3p") && ((yp1, yp2) = yp1yp2(extpW, extpPOPS))
        yp1, yp2
    end

    xpxpA = get_gtk_property(gui["xpxp1G1"], "active-id", String)
    ypA, ypB = parse_xpxp(xpxpA)
    xpxpB = get_gtk_property(gui["xpxp1G2"], "active-id", String)
    ypC, ypD = parse_xpxp(xpxpB)
    updateXPXP1(ypA, ypB, ypC, ypD, plotXPXP1, gplotPlotXPXP1)

    xpxpC = get_gtk_property(gui["xpxp2G1"], "active-id", String)
    ypA1, ypB1 = parse_xpxp(xpxpC)
    xpxpD = get_gtk_property(gui["xpxp2G2"], "active-id", String)
    ypC1, ypD1 = parse_xpxp(xpxpD)
    updateXPXP2(ypA1, ypB1, ypC1, ypD1, plotXPXP2, gplotPlotXPXP2)
end

function update_gridded_data()
    LJBuffers = @fetchfrom 2 DataAcquisitionLoops.LJBuffers
    t = convert(Array{DateTime}, LJBuffers.value.t)
    x = Dates.value.(t)
    t1Hz = LJBuffers.value.t[1]:Dates.Second(1):LJBuffers.value.t[end]
    push!(t1HzInt, Dates.value.(t1Hz))
    t10Hz = LJBuffers.value.t[1]:Dates.Millisecond(100):LJBuffers.value.t[end]
    push!(t10HzInt, Dates.value.(t10Hz))

    function getExtp(field; Δt::Int = 0)
        y = convert(Array{Float64}, field)
        ii = isless.(y, NaN)
        mx = x .- Δt
        itp = interpolate((mx[ii],), y[ii], Gridded(Linear()))
        extrapolate(itp, 0)
    end

    push!(extpU, getExtp(LJBuffers.value.u))
    push!(extpV, getExtp(LJBuffers.value.v))
    push!(extpW, getExtp(LJBuffers.value.w))
    push!(extpDir, getExtp(LJBuffers.value.dir))
    push!(extpVel, getExtp(LJBuffers.value.vel))
    push!(extpT, getExtp(LJBuffers.value.T))
    push!(extpQ, getExtp(LJBuffers.value.q))
    push!(
        extpCPC1C,
        getExtp(LJBuffers.value.CPC1; Δt = convert(Int, floor(δtCPC1C.value * 1000))),
    )
    push!(
        extpCPC2C,
        getExtp(LJBuffers.value.CPC2; Δt = convert(Int, floor(δtCPC2C.value * 1000))),
    )
    push!(extpUFC, getExtp(LJBuffers.value.CPC1 .- LJBuffers.value.CPC2))

    RS232Buffers = @fetchfrom 2 DataAcquisitionLoops.RS232Buffers

    function getExtpRS232(field; Δt::Int = 0)
        t = convert(Array{DateTime}, RS232Buffers.value.t)
        x = Dates.value.(t) .- Δt
        y = convert(Array{Float64}, field)
        ii = isless.(y, NaN)
        itp = interpolate((x[ii],), y[ii], Gridded(Linear()))
        extrapolate(itp, 0)
    end

    push!(
        extpCPC1S,
        getExtpRS232(
            RS232Buffers.value.CPC1;
            Δt = convert(Int, floor(δtCPC1S.value * 1000)),
        ),
    )
    push!(
        extpCPC2S,
        getExtpRS232(
            RS232Buffers.value.CPC2;
            Δt = convert(Int, floor(δtCPC2S.value * 1000)),
        ),
    )
    push!(extpUFS, getExtpRS232(RS232Buffers.value.CPC1 .- RS232Buffers.value.CPC2))

    tPOPS, Nt, POPSDistribution = read_pops_file()
    t = convert(Array{DateTime}, tPOPS)
    Δt = convert(Int, floor(δtPOPS.value * 1000))
    x = Dates.value.(t) .- Δt
    y = convert(Array{Float64}, Nt)
    ii = isless.(y, NaN)
    itp = interpolate((x[ii],), y[ii], Gridded(Linear()))
    push!(extpPOPS, extrapolate(itp, 0))

end

function update_graphs()
    function update(extp, plot, gplot)
        x = (t1HzInt.value .- t1HzInt.value[1]) ./ 1000.0 / 60.0
        y = extp(t1HzInt.value)
        addseries!(x, y, plot, gplot, 1, false, true)
    end

    update(extpDir.value, plotDir, gplotPlotDir)
    update(extpVel.value, plotVel, gplotPlotVel)
    update(extpW.value, plotW, gplotPlotW)
    update(extpT.value, plotT, gplotPlotT)
    update(extpQ.value, plotQ, gplotPlotQ)

    t = @fetchfrom 2 DataAcquisitionLoops.LJBuffers.value.t
    tint = Dates.value.(t)
    dt = tint[2:end] .- tint[1:end-1]
    x = (tint[2:end] .- tint[2]) ./ 1000.0 / 60.0
    addseries!(x, dt * 1.0, plotDiag1, gplotPlotDiag1, 1, false, false)

    x = (t1HzInt.value .- t1HzInt.value[1]) ./ 1000.0 / 60.0
    addseries!(x, extpCPC1C.value(t1HzInt.value), plotCPC1, gplotPlotCPC1, 1, false, true)
    addseries!(x, extpCPC2C.value(t1HzInt.value), plotCPC1, gplotPlotCPC1, 2, false, true)
    addseries!(x, extpPOPS.value(t1HzInt.value), plotCPC1, gplotPlotCPC1, 3, false, true)

    #psd = mean(hcat(RS232Buffers.value.POPSDistribution...),dims=2)
    #addseries!(Dp,psd[:], plotPOPSSize, gplotPOPSSize, 1, false, true)
end

function parseSpectra(id)
    a = split(id, "p")
    freq = (a[3] == "10Hz") ? :tenHz : :oneHz
    id = a[1]
    if id == "u"
        extp = extpU
    elseif id == "v"
        extp = extpV
    elseif id == "w"
        extp = extpW
    elseif id == "T"
        extp = extpT
    elseif id == "q"
        extp = extpQ
    elseif id == "c1c"
        extp = extpCPC1C
    elseif id == "c2c"
        extp = extpCPC2C
    elseif id == "ufc"
        extp = extpUFC
    elseif id == "c1s"
        extp = extpCPC1S
    elseif id == "c2s"
        extp = extpCPC2S
    elseif id == "ufs"
        extp = extpUFS
    elseif id == "POPS"
        extp = extpPOPS
    else
        println("Ooops")
    end
    extp, freq
end

function parseCoSpectra(id)
    a = split(id, "p")
    freq = (a[3] == "10Hz") ? :tenHz : :oneHz
    id = a[2]
    if id == "T"
        extp = extpT
    elseif id == "q"
        extp = extpQ
    elseif id == "c1c"
        extp = extpCPC1C
    elseif id == "c2c"
        extp = extpCPC2C
    elseif id == "ufc"
        extp = extpUFC
    elseif id == "c1s"
        extp = extpCPC1S
    elseif id == "c2s"
        extp = extpCPC2S
    elseif id == "ufs"
        extp = extpUFS
    elseif id == "POPS"
        extp = extpPOPS
    else
        println("Ooops")
    end
    extpW, extp, freq
end

function update_spectra()
    function average_spectra(f, S)
        fn = exp10.(range(log10.(5), stop = log10.(0.0001), length = 100))
        fE = map(i -> mean(S[(f.>fn[i]).&(f.<fn[i-1])]), 2:length(fn))
        fx = sqrt.(fn[2:end] .* fn[1:end-1])
        ii = .~isnan.(fE)
        fx[ii], fE
    end

    id = get_gtk_property(gui["spectraLeft"], "active-id", String)
    extp, freq = parseSpectra(id)
    t1, t10, extp = t1HzInt.value, t10HzInt.value, extp.value
    f, E, σ = PowerSpectra.powerSpectrum(extp, t1, t10; freq = freq)
    set_gtk_property!(gui["spectra1FieldG1"], :text, @sprintf("%.2f", σ))
    x, y = average_spectra(f, E .* f)
    addseries!(f, E .* f, plotSpectra1, gplotSpectra1, 1, false, true)

    id = get_gtk_property(gui["spectraRight"], "active-id", String)
    extp, freq = parseSpectra(id)
    t1, t10, extp = t1HzInt.value, t10HzInt.value, extp.value
    f, E, σ = PowerSpectra.powerSpectrum(extp, t1, t10; freq = freq)
    set_gtk_property!(gui["spectra1FieldG2"], :text, @sprintf("%.2f", σ))
    x, y = average_spectra(f, E .* f)
    addseries!(f, E .* f, plotSpectra1, gplotSpectra1, 2, false, true)

    id = get_gtk_property(gui["coSpectraLeft"], "active-id", String)
    extp1, extp2, freq = parseCoSpectra(id)
    t1, t10, extp1, extp2 = t1HzInt.value, t10HzInt.value, extp1.value, extp2.value
    f, E, cov = PowerSpectra.coSpectrum(extp1, extp2, t1, t10; freq = freq)
    set_gtk_property!(gui["spectra2FieldG1"], :text, @sprintf("%.3f", cov))
    x, y = average_spectra(f, f .* E)
    addseries!(f, E .* f, plotSpectra2, gplotSpectra2, 1, false, true)

    id = get_gtk_property(gui["coSpectraRight"], "active-id", String)
    extp1, extp2, freq = parseCoSpectra(id)
    t1, t10, extp1, extp2 = t1HzInt.value, t10HzInt.value, extp1.value, extp2.value
    f, E, cov = PowerSpectra.coSpectrum(extp1, extp2, t1, t10; freq = freq)
    set_gtk_property!(gui["spectra2FieldG2"], :text, @sprintf("%.3f", cov))
    x, y = average_spectra(f, f .* E)
    addseries!(f, E .* f, plotSpectra2, gplotSpectra2, 2, false, true)
end

function compute_lags(lags)
    LJBuffers = @fetchfrom 2 DataAcquisitionLoops.LJBuffers
    RS232Buffers = @fetchfrom 2 DataAcquisitionLoops.RS232Buffers
    t = convert(Array{DateTime}, LJBuffers.value.t)
    x = Dates.value.(t)
    t1Hz = LJBuffers.value.t[1]:Dates.Second(1):LJBuffers.value.t[end]
    t10Hz = LJBuffers.value.t[1]:Dates.Millisecond(100):LJBuffers.value.t[end]
    t1Hz = Dates.value.(t1Hz)
    t10Hz = Dates.value.(t10Hz)

    function getExtp(field; Δt::Int = 0)
        y = convert(Array{Float64}, field)
        itp = interpolate((x .- Δt,), y, Gridded(Linear()))
        extrapolate(itp, 0)
    end

    function getExtpRS232(field; Δt::Int = 0)
        local t = convert(Array{DateTime}, RS232Buffers.value.t)
        local x = Dates.value.(t)
        local y = convert(Array{Float64}, field)
        itp = interpolate((x .- Δt,), y, Gridded(Linear()))
        extrapolate(itp, 0)
    end

    function lcor(t)
        extpW = getExtp(LJBuffers.value.w)
        extpCPC1C = getExtp(LJBuffers.value.CPC1; Δt = convert(Int, t * 1000))
        extpCPC2C = getExtp(LJBuffers.value.CPC2; Δt = convert(Int, t * 1000))

        w = PowerSpectra.detrendLinear(t10Hz .* 1.0, extpW(t10Hz))
        CPC1C = PowerSpectra.detrendLinear(t10Hz .* 1.0, extpCPC1C(t10Hz))
        CPC2C = PowerSpectra.detrendLinear(t10Hz .* 1.0, extpCPC2C(t10Hz))

        r1 = cor(w, CPC1C)
        r2 = cor(w, CPC2C)

        extpCPC1S = getExtpRS232(RS232Buffers.value.CPC1; Δt = convert(Int, t * 1000))
        extpCPC2S = getExtpRS232(RS232Buffers.value.CPC2; Δt = convert(Int, t * 1000))

        function getExtpPOPS(; Δt = convert(Int, t * 1000))
            tPOPS, Nt, POPSDistribution = read_pops_file()
            Δt = convert(Int, floor(t * 1000))
            tP = convert(Array{DateTime}, tPOPS)
            xp = Dates.value.(tP) .- Δt
            yp = convert(Array{Float64}, Nt)
            df = DataFrame(x = xp, y = yp)
            unique!(df)
            itp = interpolate((df[!, :x],), df[!, :y], Gridded(Linear()))
            extpPOPS = extrapolate(itp, 0)
        end

        extpPOPS = getExtpPOPS(Δt = convert(Int, t * 1000))


        w = PowerSpectra.detrendLinear(t1Hz .* 1.0, extpW(t1Hz))
        CPC1S = PowerSpectra.detrendLinear(t1Hz .* 1.0, extpCPC1S(t1Hz))
        CPC2S = PowerSpectra.detrendLinear(t1Hz .* 1.0, extpCPC2S(t1Hz))
        POPS = PowerSpectra.detrendLinear(t1Hz .* 1.0, extpPOPS(t1Hz))

        r3 = cor(w, CPC1S)
        r4 = cor(w, CPC2S)
        r5 = cor(w, POPS)
        [r1, r2, r3, r4, r5]
    end
    r = (hcat(lcor.(lags)...)')[:, :]

    addseries!(collect(lags), r[:, 1], plotLag1, gplotPlotLag1, 1, true, true)
    addseries!(
        [δtCPC1C.value, δtCPC1C.value],
        [0.0, 1],
        plotLag1,
        gplotPlotLag1,
        2,
        true,
        true,
    )
    addseries!(collect(lags), r[:, 2], plotLag2, gplotPlotLag2, 1, true, true)
    addseries!(
        [δtCPC2C.value, δtCPC2C.value],
        [0.0, 1],
        plotLag2,
        gplotPlotLag2,
        2,
        true,
        true,
    )
    addseries!(collect(lags), r[:, 3], plotLag3, gplotPlotLag3, 1, true, true)
    addseries!(
        [δtCPC1S.value, δtCPC1S.value],
        [0.0, 1],
        plotLag3,
        gplotPlotLag3,
        2,
        true,
        true,
    )
    addseries!(collect(lags), r[:, 4], plotLag4, gplotPlotLag4, 1, true, true)
    addseries!(
        [δtCPC2S.value, δtCPC2S.value],
        [0.0, 1],
        plotLag4,
        gplotPlotLag4,
        2,
        true,
        true,
    )
    addseries!(collect(lags), r[:, 5], plotLag5, gplotPlotLag5, 1, true, true)
    addseries!(
        [δtPOPS.value, δtPOPS.value],
        [0.0, 1],
        plotLag5,
        gplotPlotLag5,
        2,
        true,
        true,
    )
end

function read_pops_file()
    file = @fetchfrom 2 DataAcquisitionLoops.POPSdataFilename.value

    s = open(file) do io
        read(io, String)
    end

    lines = (split(s, '\n'))[2:end-1]

    a = (length(lines) > 1800) ? length(lines) - 1800 : 1

    t = map(lines[a:end]) do s
        y = split(s, ',')
        t = Dates.DateTime(y[1])
    end

    Np = map(lines[a:end]) do s
        y = split(s, ',')
        Q = parse(Float64, y[10])
        Np = map(i -> parse(Float64, y[i]), 14:29) ./ Q
    end

    Np = (hcat(Np...)')[:, :]

    POPSDistribution = map(i -> mean(Np[:, i]), 1:16)
    Nt = map(i -> sum(Np[i, :]), 1:length(lines[a:end]))
    t, Nt, POPSDistribution
end
