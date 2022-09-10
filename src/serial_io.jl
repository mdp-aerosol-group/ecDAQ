using LibSerialPort

function configureCPC(type, port)
    if type == :TSI3762
	    baudRate = 9600
	    dataBits = 7
	    stopBits = 1
        parity = SP_PARITY_EVEN
    elseif type == :TSI3776C
        baudRate = 115200
        dataBits = 8
        stopBits = 1
        parity = SP_PARITY_NONE
    elseif type == :POPS
		baudRate = 9600
		dataBits = 8
		stopBits = 1
		parity = SP_PARITY_NONE
	end

	serialPort = port
	port = sp_get_port_by_name(serialPort)
	sp_open(port, SP_MODE_READ_WRITE)
	config = sp_get_config(port)
	sp_set_config_baudrate(config, baudRate)
	sp_set_config_parity(config, parity)
	sp_set_config_bits(config, dataBits)
	sp_set_config_stopbits(config, stopBits)
	sp_set_config_rts(config, SP_RTS_OFF)
	sp_set_config_cts(config, SP_CTS_IGNORE)
	sp_set_config_dtr(config, SP_DTR_OFF)
	sp_set_config_dsr(config, SP_DSR_IGNORE)

	sp_set_config(port, config)

	return port, type
end

function readCPC(port, CPCType, fileCPC)
	sp_drain(port)
	sp_flush(port, SP_BUF_OUTPUT)

	if CPCType == :TSI3022 
		sp_nonblocking_write(port, "RD\r");
		nbytes_read, bytes = sp_nonblocking_read(port,  10)
		c = String(bytes)
		f = split(c,"\r")
		N = try 
			parse(Float64,f[1])
		catch 
			missing
		end
	end

	if CPCType == :TSI3762 
		sp_nonblocking_write(port, "RB\r")
		nbytes_read, bytes = sp_nonblocking_read(port,  10)
		c = String(bytes)
		f = split(c,"\r")
		N = try 
			parse(Float64,f[1])/60.0
		catch 
			missing
		end
		N = N
	end

	if (CPCType == :TSI3771) || (CPCType == :TSI3772) || (CPCType == :TSI3776C) 
		sp_nonblocking_write(port, "RALL\r");
		nbytes_read, bytes = sp_nonblocking_read(port,  100)
		
		c = String(bytes)
		str = split(c,'\0')
		open(path*String(CPCType)*fileCPC, "a") do io
			t = Dates.now()
			tint = @sprintf(",%i,", Dates.value(t))
			write(io, Dates.format(Dates.now(), Dates.ISODateTimeFormat)*tint)
			map(i->write(io, i), str)
		end
	
		f = split(c,",")
		N = try 
			parse(Float64, f[1])
		catch
			missing
		end
	end

	N,c
end

function read_POPS(port,filePOPS)
	sp_drain(port)
	sp_flush(port, SP_BUF_OUTPUT)
	nbytes_read, bytes = sp_nonblocking_read(port, 1512)
	c = String(bytes)
	
	d = split(c,'\0')
	e = d[map(length, d) .> 0]
	if (length(e) == 0)
		return 0, [0 for i = 1:16]
	end
	f = split(e[1], '\n')
	str = f[map(length, f) .> 0]

	open(filePOPS, "a") do io
		x = map(str) do s
			if length(s) <= 1
				condition = try 
					s[1] == 'P'
				catch
					false
				end
			end
			if length(s) > 1
				condition = try 
					s[1:2] == "PO"
				catch
					false
				end
			end

			if condition
				t = Dates.now()
				tint = @sprintf(",%i,", Dates.value(t))
				write(io, '\n'*Dates.format(t, Dates.ISODateTimeFormat)*tint*s)
				push!(POPSLine.value,s)
			else
				write(io, s)
				push!(POPSLine.value,s)
			end
		end
	end
	a = split(*(POPSLine.value...), '\r')
	i = map(a) do s
		x = split(s, ',')
		if length(x) == 27
			Np = try 
				map(i->parse(Float64,x[i]),12:27)
			catch 
				[0 for i = 1:16]
			end
			Q = try
				parse(Float64,x[8])
			catch
				1.0
			end
			Nt = try
				sum(Np./Q)
			catch 
				[0 for i = 1:16]
			end
			Nt, Np./Q			
		end
	end
	out = try
		i[i .!= nothing]
	catch
		nothing
	end
	if out === nothing
		return 0, [0 for i = 1:16]
	else
		return out[end]
	end
end

function serial_read(portCPC1, typeCPC1, portCPC2, typeCPC2, portPOPS, filePOPS, fileCPC)
    t = now()
    N0 = [10,15.0,30,20,10,1.0, 0.1, 0.04, 0.005]
    r = readCPC(portCPC1, typeCPC1, fileCPC)
    CPC1 = r[1]
    r = readCPC(portCPC2, typeCPC2, fileCPC)
    CPC2 = r[1]
    #x = map(i->rand(Poisson(i*2.0),1), N0)
	#dN = vcat(x...)./2.0
	#POPS = sum(dN)
	Nt, dN = read_POPS(portPOPS, filePOPS)

	push!(RS232dataStream, DataFrame(t=t,tint=Dates.value(t),CPC1=CPC1,CPC2=CPC2,POPS=Nt,POPSDistribution=[dN]))
end
