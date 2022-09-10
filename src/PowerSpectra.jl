#+
# Module PowerSpectras
# Compute power spectra from gridded 1 Hz and 10 Hz data
#
# 
#-
module PowerSpectra

using FFTW, Statistics

export powerSpectrum, detrendLinear, cosineTaper!

# Linear regression m = b + mx
linfit(x::Array{Float64},y::Array{Float64}) = [ones(length(x),1) x]\y

# Remove linear trend. Results in y' 
function detrendLinear(x::Array{Float64},y::Array{Float64})
     Ax = linfit(x,y)
     y .- (Ax[1].+ Ax[2].*x)
end

# Apply a cosine taper to the edge of the time series
function cosineTaper!(y::Array{Float64})
    n = length(y)
    m = floor(n/20.0)
    for k = 1:1:n 
         w = 1
         if k < m 
            w = 0.5*(1-cos(k*π/(m+1)))
         elseif k > n-m-2
            w = 0.5*(1-cos((n-k-1)*π/(m+1)))
         end
         y[k] = y[k]*w
    end
end

function powerSpectrum(extp, t1HzInt, t10HzInt; freq=:oneHz)
   t = (freq == :tenHz) ? t10HzInt : t1HzInt
   y = extp(t)
   y = detrendLinear(t*1.0,y)
   N = length(y)
   y = (N % 2) == 1 ? y[1:N-1] : y
   N = length(y)
   n = Int(N/2)
   cosineTaper!(y)
   Fa = FFTW.fft(y)/N
   σ=var(y)
   
   E = (2.0*abs.(Fa).^2.0)/σ
   Hz = 1000.0/(t[2]-t[1])
   f = Hz*collect(range(1,stop=n,length=n))/N
   df = (f[2:n]-f[1:n-1])
   f[1:n-1],E[2:n],σ
end

function coSpectrum(extp1, extp2, t1HzInt, t10HzInt; freq=:oneHz)
   t = (freq == :tenHz) ? t10HzInt : t1HzInt
   ya = extp1(t)
   yb = extp2(t)
   y1 = detrendLinear(t*1.0, ya)
   y2 = detrendLinear(t*1.0, yb)

   N = length(y1)
   y1 = (N % 2) == 1 ? y1[1:N-1] : y1
   y2 = (N % 2) == 1 ? y2[1:N-1] : y2
   N = length(y1)
   n = Int(N/2)

   cov = mean(y1 .* y2)-mean(y1)*mean(y2)
   R = cov ./(std(y1)*std(y2))

   Fa = FFTW.fft(y1)/N
   Fb = FFTW.fft(y2)/N

   Sa = 2.0*abs.(Fa).^2
   Sb = 2.0*abs.(Fb).^2

   Co = 2.0 * (real(Fa).* real(Fb) .+ imag(Fa) .* imag(Fb))

   Hz = 1000.0/(t[2]-t[1])
   f = Hz*collect(range(1,stop=n,length=n))/N

   Sa = Sa[2:n]./var(ya)  # normalize by variance
   Sb = Sb[2:n]./var(yb)  # normalize by variance
   Co = Co[2:n]./cov      # normalize by covariance

   f[1:n-1], Co, cov
end

end
