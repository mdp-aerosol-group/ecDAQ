using Random, Distributions

function synthetic_labjack()
    t = now()
    u = (rand(1))[1]
    v = (rand(1))[1]
    w = (rand(1))[1]
    vel = uv2vel(u,v)
    dir = uv2dir(u,v)
    T = (rand(1))[1]
    q = (rand(1))[1]
    CPC1 = 350.0 + 15*(rand(1))[1]
    CPC2 = 230.0 + 10*(rand(1))[1]

    push!(LJdataStream, DataFrame(t=t,tint=Dates.value(t),u=u,v=v,w=w,vel=vel,dir=dir,T=T,q=q,CPC1=CPC1,CPC2=CPC2))
end

function synthetic_serial()
    t = now()
    N0 = [10,15.0,30,20,10,1.0, 0.1, 0.04, 0.005]
    CPC1 = 360.0 + 15*(rand(1))[1]
    CPC2 = 220.0 + 10*(rand(1))[1]
    x = map(i->rand(Poisson(i*2.0),1), N0)
    dN = vcat(x...)./2.0
    POPS = sum(dN)

    push!(RS232dataStream, DataFrame(t=t,tint=Dates.value(t),CPC1=CPC1,CPC2=CPC2,POPS=POPS,POPSDistribution=[dN]))
end


# Convert u/v to velocity
uv2vel(u::Float64, v::Float64) = sqrt(u^2.0 + v^2.0)

# Convert u/v to wind direction
function uv2dir(u::Float64, v::Float64)
    if u > 0.0
        rad = atan(v/u)
    elseif (u < 0.0) & (v >= 0.0)
        rad = atan(v/u) + π
    elseif (u < 0.0) & (v < 0.0)
        rad = atan(v/u) - π
    elseif (u == 0.0) & (v > 0.0)
        rad = π/2.0
    elseif (u == 0.0) & (v < 0.0)
        rad = -π/2.0
    elseif (u == 0.0) & (v == 0.0)
        rad = missing
    else
        rad = missing
        println("This case should be impossible\n")
    end

    rad*180.0/π  
end