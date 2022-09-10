using LabjackU6Library, Reactive, DataFrames, Dates

include("synthetic_data_stream.jl")
include("labjack_io.jl")

const valveUP      = Signal(false)
const valveDOWN    = Signal(false)

t = now()
const lj = DataFrame(t=t,tint=Dates.value(t),u=0.0,v=0.0,w=0.0,vel=0.0,dir=0.0,T=0.0,q=0.0,c1=0,c2=0,CPC1=0.0,CPC2=0.0,Tlj=0.0,RHrot = 0.0,Trot=0.0)
const LJdataStream = Signal(lj)

LJID = -1
HANDLE = openUSBConnection(LJID)
caliInfo = getCalibrationInformation(HANDLE)

tenHz = every(1)      # 10 Hz timer for LJ

labjackDAQ  = map(_->labjackReadWrite(HANDLE, caliInfo),tenHz)
