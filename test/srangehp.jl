
using StaticRanges: srangehp

b = (SVal(Int128(1)), SVal(Int128(1)))
s = (SVal(Int128(1)), SVal(Int128(1)))
nb = SVal(1)
l = SVal(2)
f = SVal(1)
T = Float64

# src/srangehp.jl line 1
@test @inferred(srangehp(T, b, s, nb, l, f)) == StaticRanges.SRange{Float64,HPSVal{Float64,1.0,0.0},HPSVal{Float64,1.0,0.0},2.0,2,1}()


# src/srangehp.jl line 7
@test @inferred(srangehp(Float32, b, s, nb, l, f)) == StaticRanges.SRange{Float32,SVal{1.0,Float64},SVal{1.0,Float64},2.0,2,1}()

# src/srangehp.jl line 21
b = SVal(1.0)
s = SVal(1.0)
@test @inferred(srangehp(T, b, s, nb, l, f)) == StaticRanges.SRange{Float64,HPSVal{Float64,1.0,0.0},HPSVal{Float64,1.0,0.0},2.0,2,1}()

# src/srangehp.jl line 35
b = (SVal(1.0), SVal(0.0))
s = (SVal(1.0), SVal(0.0))
@test @inferred(srangehp(T, b, s, nb, l, f)) == StaticRanges.SRange{Float64,HPSVal{Float64,1.0,0.0},HPSVal{Float64,1.0,0.0},2.0,2,1}()

# src/srangehp.jl line 49
@test @inferred(srangehp(Float32, b, s, nb, l, f)) == StaticRanges.SRange{Float32,SVal{1.0,Float64},SVal{1.0,Float64},2.0f0,2,1}()

# src/srangehp.jl line 59
b = SVal(1.0)
s = SVal(1.0)
@test @inferred(srangehp(Float32, b, s, nb, l, f)) == StaticRanges.StaticRanges.SRange{Float32,SVal{1.0,Float64},SVal{1.0,Float64},2.0f0,2,1}()
