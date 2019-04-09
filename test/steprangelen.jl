using StaticRanges: steprangelen

@testset "steprangelen" begin
    b = SVal(1.0)
    s = SVal(2.0)
    l = SVal(10)
    f = SVal(1)

    # src/steprangelen.jl line 1
    @test @inferred(steprangelen(b, s, l , f)) == StaticRanges.SRange{Float64,SVal{1.0,Float64},SVal{2.0,Float64},19.0,10,1}()
    @test @inferred(steprangelen(Float64, b, s, l, f)) == StaticRanges.SRange{Float64,SVal{1.0,Float64},SVal{2.0,Float64},19.0,10,1}()


    # src/steprangelen.jl line 9
    b = HPSVal{Float64, 1.0,0.0}()
    s = HPSVal{Float64, 2.0,0.0}()

    @test @inferred(steprangelen(b, s, l, f)) == StaticRanges.SRange{Float64,HPSVal{Float64,1.0,0.0},HPSVal{Float64,2.0,0.0},19.0,10,1}()

    # src/steprangelen.jl line 28
    @test @inferred(steprangelen(Float64, b, s, l, f)) == StaticRanges.SRange{Float64,HPSVal{Float64,1.0,0.0},HPSVal{Float64,2.0,0.0},19.0,10,1}()
end