using StaticRanges: floatrange

T = Float32
b = SVal(1)
s = SVal(2)
l = SVal(10)
d = SVal(1)

# src/floatrange line 1
@test @inferred(floatrange(T, b, s, l, d)) == StaticRanges.SRange{Float32,SVal{1.0,Float64},SVal{2.0,Float64},19.0f0,10,1}()

b = SVal(1.0)
s = SVal(2.0)
d = SVal(1.0)
# src/floatrange line 19
@test @inferred(floatrange(b, s, l, d)) == StaticRanges.SRange{Float64,HPSVal{Float64,1.0,0.0},HPSVal{Float64,2.0,0.0},19.0,10,1}()
