#+ 
# Functions that handle Labjack IO 
#

# This function sets the send and receive buffers
function setupLabjackBuffers(BitFIO3,BitFIO4)
    # See pg. 83 of U6 Datasheet for protocol
    # Maintain C style zero indexing for bytes by using +1

    # 8 AIN 24bit, 1 AIN14 (T), 2 FIO Channels Dir + 2 FIO Write + 3 Counter
    # IOType input bytes  = 8*4 + 1*4 + 2*2 + 2*2 + 2*2 = 48 bytes
    # IOType output bytes = 8*3 + 1*3 + 2*0 + 2*0 + 2*4 = 35 bytes

    # Send buffer in words = (1 + 48 + 1)/2 = 25
    # Receive buffer in words  = (8 + 35 + 1)/2 = 22
    sl,rl = (25*2+6),(22*2+8)   # Length of send buffer,receive buffer in bytes
    sendBuff, rec = zeros(UInt8,sl), zeros(UInt8,rl)

    # Block 1 Bytes 1-5 Configure Basic Setup
    # Bytes 0,4,5 are reserved for checksum
    sendBuff[1+1] = UInt8(0xF8)    # Command byte
    sendBuff[2+1] = 24             # Number of data words
    sendBuff[3+1] = UInt8(0x00)    # Extended command number

    # Block 2 Echo + Bytes 7-XX
    # Bytes 7-XX Configure Channels
    # Must be even number of bytes
    sendBuff[6+1] = 0;           # Echo

    # AIN0
    sendBuff[7+1]  = 2;          # IOType is AIN24
    sendBuff[8+1]  = 0;          # Channel 0
    sendBuff[9+1]  = 9 + 0*16;   # Resolution & Gain
    sendBuff[10+1] = 0 + 0*128;  # Settling & Differential 

    # AIN1
    sendBuff[11+1] = 2;          # IOType is AIN24
    sendBuff[12+1] = 1;          # Channel 1
    sendBuff[13+1] = 9 + 0*16;   # Resolution & Gain
    sendBuff[14+1] = 0 + 0*128;  # Settling & Differential

    # AIN2
    sendBuff[15+1] = 2;          # IOType is AIN24
    sendBuff[16+1] = 2;          # Channel 2
    sendBuff[17+1] = 9 + 0*16;   # Resolution & Gain
    sendBuff[18+1] = 0 + 0*128;  # Settling & Differential

    # AIN3
    sendBuff[19+1] = 2;          # IO Type is AIN24
    sendBuff[20+1] = 3;          # Channel 3
    sendBuff[21+1] = 9 + 0*16;   # Resolution & Gain
    sendBuff[22+1] = 0 + 0*128;  # Settling & Differential

    # AIN4
    sendBuff[23+1] = 2;          # IO Type is AIN24
    sendBuff[24+1] = 4;          # Channel 4
    sendBuff[25+1] = 9 + 0*16;   # Resolution & Gain
    sendBuff[26+1] = 0 + 0*128;  # Settling & Differential

	# AIN5
    sendBuff[27+1] = 2;          # IO Type is AIN24
    sendBuff[28+1] = 5;          # Channel 5
    sendBuff[29+1] = 9 + 0*16;   # Resolution & Gain
    sendBuff[30+1] = 0 + 0*128;  # Settling & Differential

	# AIN6
    sendBuff[31+1] = 2;          # IO Type is AIN24
    sendBuff[32+1] = 6;          # Channel 5
    sendBuff[33+1] = 9 + 0*16;   # Resolution & Gain
    sendBuff[34+1] = 0 + 0*128;  # Settling & Differential

	# AIN7
    sendBuff[35+1] = 2;          # IO Type is AIN24
    sendBuff[36+1] = 7;          # Channel 5
    sendBuff[37+1] = 9 + 0*16;   # Resolution & Gain
    sendBuff[38+1] = 0 + 0*128;  # Settling & Differential

    # AIN14
    sendBuff[39+1] = 2           # IOType is AIN24
    sendBuff[40+1] = 14          # Positive channel = 14 (temperature sensor)
    sendBuff[41+1] = 9 + 0*16    # Resolution & Gain 
    sendBuff[42+1] = 0 + 0*128   # SettlingFactor & Differential

    # EIO
    sendBuff[43+1] = 13;         # IOType is BitDirWrite
    sendBuff[44+1] = 11 + 1*128; # EIO & Direction = 1 (Output)

    # EIO
    sendBuff[45+1] = 13;         # IOType is BitDirWrite
    sendBuff[46+1] = 12 + 1*128; # EIO & Direction = 1 (Output)

    # EIO
    sendBuff[47+1] = 11;         # IOType is BitState Write
    sendBuff[48+1] = 11 + UInt8(BitFIO3)*128;  # EIO & Bit

    # EIO
    sendBuff[49+1] = 11;         # IOType is BitState Write
    sendBuff[50+1] = 12 + UInt8(BitFIO4)*128;  # EIO & Bit

    # Counter0
    sendBuff[51+1] = 54;         # IOType is Counter0
    sendBuff[52+1] = 0;          # Reset counter

    # Counter1
    sendBuff[53+1] = 55;         # IOType is Counter1
    sendBuff[54+1] = 0;          # Reset counter

    # Padding bye (size of a packet must be an even number of bytes)
    sendBuff[55+1] = 0;

    # Create labjack buffer data types to pass to C-functions
    send =  labjackBuffer{sl}(NTuple{sl,UInt8}(sendBuff[i] for i in 1:sl))
    rec =  labjackBuffer{rl}(NTuple{rl,UInt8}(rec[i] for i in 1:rl))

    # Fills bytes 0,4,5 with checksums
    extendedChecksum!(send)
    return send, rec
end

function labjackReadWrite(HANDLE, caliInfo)
    sendIt, recordIt = setupLabjackBuffers(~valveUP.value, ~valveDOWN.value)

    labjackSend(HANDLE,sendIt)
    labjackRead!(HANDLE,recordIt)
    AIN0 = calibrateAIN(caliInfo,recordIt,9,0,1,10,11,12)  # Calibrate AIN0
    AIN1 = calibrateAIN(caliInfo,recordIt,9,0,1,13,14,15)  # Calibrate AIN1
    AIN2 = calibrateAIN(caliInfo,recordIt,9,0,1,16,17,18)  # Calibrate AIN2
    AIN3 = calibrateAIN(caliInfo,recordIt,9,0,1,19,20,21)  # Calibrate AIN3
    AIN4 = calibrateAIN(caliInfo,recordIt,9,0,1,22,23,24)  # Calibrate AIN4
    AIN5 = calibrateAIN(caliInfo,recordIt,9,0,1,25,26,27)  # Calibrate AIN5
    AIN6 = calibrateAIN(caliInfo,recordIt,9,0,1,28,29,30)  # Calibrate AIN5
    AIN7 = calibrateAIN(caliInfo,recordIt,9,0,1,31,32,33)  # Calibrate AIN5
	AIN14 = calibrateAIN(caliInfo,recordIt,9,0,1,34,35,36)  # Calibrate AIN14
    Tk = caliInfo.ccConstants[23]*AIN14 + caliInfo.ccConstants[24] # Temp in K
	counts1 =  recordIt.buff[37] + recordIt.buff[38]*256 + recordIt.buff[39]*65536 + recordIt.buff[40]*16777216
	counts2 =  recordIt.buff[41] + recordIt.buff[42]*256 + recordIt.buff[43]*65536 + recordIt.buff[44]*16777216
    
    frame = LJdataStream.value
    N1 = try
        (frame.CPC1)[1]
    catch
        counts1
    end

    N2 = try
        (frame.CPC2)[2]
    catch
        counts2
    end
    t = now()

    u=AIN0*10.0-25.0
    v=AIN1*10.0-25.0
    w=AIN2*10.0-25.0
    T=(AIN3*20.0+220.0)-273.15
    CPC1 = convert(Float64,(counts1 - (frame.c1)[1])./0.1/(0.065*16.6666))
    CPC2 = convert(Float64,(counts2 - (frame.c2)[1])./0.1/(3.0*16.6666))
    Tlj = Tk-273.15
    RHrot = AIN5/5.0*100.0
    Trot = AIN4/5.0*100.0 - 50.0
    vel = uv2vel(u,v)
    dir = uv2dir(u,v)
    push!(LJdataStream, DataFrame(t=t,tint=Dates.value(t),u=u,v=v,w=w,vel=vel,dir=dir,T=T,c1=counts1,c2=counts2,
                                  CPC1=CPC1,CPC2=CPC2,Tlj=Tlj,Trot=Trot,RHrot=RHrot))
end