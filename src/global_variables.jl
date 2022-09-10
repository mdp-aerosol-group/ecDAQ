# + 
# This file defines global constants and Signals
# The signals are defined as const to indicate type stability
#
# -

Dmin =
    [115.0, 125, 135, 150, 165, 185, 210, 250, 350, 475, 575, 855, 1220, 1530, 1990, 2585]
Dmax =
    [125, 135, 150, 165, 185, 210, 250, 350, 475, 575, 855, 1220, 1530, 1990, 2585, 3370.0]
const DpPOPS = Dmin .+ (Dmax .- Dmin) ./ 2.0
const dlnDpPOPS = log.(Dmax ./ Dmin)

const _Gtk = Gtk.ShortNames
const black = RGBA(0, 0, 0, 1)
const red = RGBA(0.8, 0.2, 0, 1)
const mblue = RGBA(0, 0, 0.8, 1)
const mgrey = RGBA(0.4, 0.4, 0.4, 1)
const lpm = 1.666666e-5
const path = mapreduce(a -> "/" * a, *, (pwd()|>x->split(x, "/"))[2:3]) * "/Data/"

# Extrapolation Signals - these hold the data from the circ buffer and are used
#                         to interpolate the data onto a fixed 1Hz or 10 Hz grid
t = @fetchfrom 2 DataAcquisitionLoops.t
const extp = extrapolate(interpolate(([0, 1],), [0.0, 1], Gridded(Linear())), 0)
const extpU = Signal(extp)
const extpV = Signal(extp)
const extpW = Signal(extp)
const extpVel = Signal(extp)
const extpDir = Signal(extp)
const extpT = Signal(extp)
const extpQ = Signal(extp)
const extpCPC1C = Signal(extp)
const extpCPC2C = Signal(extp)
const extpCPC1S = Signal(extp)
const extpCPC2S = Signal(extp)
const extpUFC = Signal(extp)
const extpUFS = Signal(extp)
const extpPOPS = Signal(extp)
const t1HzInt = Signal(Dates.value.(t:Dates.Second(1):(t+Dates.Minute(1))))
const t10HzInt = Signal(Dates.value.(t:Dates.Millisecond(100):(t+Dates.Minute(1))))
const δtCPC1C = Signal(0.0)
const δtCPC2C = Signal(0.0)
const δtCPC1S = Signal(0.0)
const δtCPC2S = Signal(0.0)
const δtPOPS = Signal(0.0)

const datestr = @fetchfrom 2 DataAcquisitionLoops.datestr
const HHMM = @fetchfrom 2 DataAcquisitionLoops.HHMM

# Processed data stream
function ECcircBuff(n)
    t = CircularBuffer{DateTime}(n)
    TKE = CircularBuffer{Float64}(n)
    ustar = CircularBuffer{Float64}(n)
    zoL = CircularBuffer{Float64}(n)
    wT = CircularBuffer{Float64}(n)
    wq = CircularBuffer{Float64}(n)
    wc1c = CircularBuffer{Float64}(n)
    wc2c = CircularBuffer{Float64}(n)
    wc12c = CircularBuffer{Float64}(n)
    wc1s = CircularBuffer{Float64}(n)
    wc2s = CircularBuffer{Float64}(n)
    wc12s = CircularBuffer{Float64}(n)
    wc3s = CircularBuffer{Float64}(n)
    POPSDistribution = CircularBuffer{Array{Float64,1}}(n)

    (
        t = t,
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
        POPSDistribution = POPSDistribution,
    )
end

const Dp = [200, 300, 400, 500, 600, 700, 800, 900, 1200.0]
const ECBuffers = Signal(ECcircBuff(288))  # 30 min @ 10 Hz
const EC = DataFrame(
    t = t,
    tint = Dates.value(t),
    TKE = 0.0,
    ustar = 0.0,
    zoL = 0.0,
    wT = 0.0,
    wq = 0.0,
    wc1c = 0.0,
    wc2c = 0.0,
    wc12c = 0.0,
    wc1s = 0.0,
    wc2s = 0.0,
    wc12s = 0.0,
    wc3s = 0.0,
    POPSdistribution = [Dp],
)
const path = mapreduce(a -> "/" * a, *, (pwd()|>x->split(x, "/"))[2:3]) * "/Data/"
const ECdataFilename =
    Signal(path * "ECdataStream_" * datestr.value * "_" * HHMM.value * ".csv")
const ECdataStream = Signal(EC)
ECdataStream.value |> CSV.write(ECdataFilename.value)

const newDay = map(droprepeats(datestr)) do x
    push!(ECdataFilename, path * "ECdataStream_" * datestr.value * "_" * HHMM.value * ".csv")
end
