function read_pops_files()
    s = open("/home/aerosol/Data/POPSdataStream_20191111_1633.txt") do file 
        read(file, String)    
    end
    
    lines = (split(s, '\n'))[2:end-1]

    a = (length(s1) > 1800) ? length(s1) - 1800 : 1

    t = map(lines[a:end]) do s
        y = split(s, ',')
        t = Dates.DateTime(y[1])
    end

    Np = map(lines[a:end]) do s
        y = split(s, ',')
        Q = parse(Float64,y[9])
        Np = map(i->parse(Float64,y[i]),13:28)./Q
    end

    Np = (hcat(Np...)')[:,:]
    
    POPSDistribution = map(i->mean(Np[:,i]), 1:16)
    Nt = map(i->sum(Np[i,:]), 1:length(lines[a:end]))
    t, Nt, POPSDistribution
end

t, Nt, POPSDistribution = read_pops_files()

# x = split(c)
# ms = x[1]
# y = split(ms, ',')
# Np = try
#      map(i->parse(Float64,y[i]),12:27)
# catch
#     [missing for i = 1:16]
# end
# Q = try
#     parse(Float64,y[8])
#    catch
#    missing
# end 
# Nt = try
#     sum(Np./Q)
# catch
#     missing
# end
# Nt, Np./Q

sp_drain(port)
sp_flush(port, SP_BUF_OUTPUT)
for i = 1:100
    nbytes_read, bytes = sp_nonblocking_read(port,10000)
end

for i = 1:1000
    Nt, Np = read_POPS(port, "asdf")
    println(Nt, Np)
    sleep(1)
end