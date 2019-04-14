using StaticRanges: linspace, linspace1, linrange

@testset "linspace" begin
    T = Int
    b = SVal(1)
    e = SVal(10)
    l = SVal(5)

    # src/linspace.jl line 1
    @test @inferred(linspace(T, b, e, l)) == StaticRanges.SRange{Float64,HPSVal{Float64,1.0,0.0},HPSVal{Float64,2.25,0.0},10.0,5,1}()

    # src/linspace.jl line 15
    @test @inferred(linspace(Float64, b, e, l)) == StaticRanges.SRange{Float64,HPSVal{Float64,1.0,0.0},HPSVal{Float64,2.25,0.0},10.0,5,1}()

    # src/linspace.jl line 24
    b = SVal(1.0)
    e = SVal(10.0)
    f = SVal(1)
    l = SVal(5)
    @test @inferred(linspace(b, e, f, l)) == StaticRanges.SRange{Float64,HPSVal{Float64,1.0,0.0},HPSVal{Float64,1.0,0.0},5.0,5,1}()


    b = SVal(1)
    e = SVal(10)
    l = SVal(5)
    d = SVal(1)

    # src/linspace.jl line 73
    @test @inferred(linspace(Float64, b, e, l, d)) == StaticRanges.SRange{Float64,HPSVal{Float64,1.0,0.0},HPSVal{Float64,2.25,0.0},10.0,5,1}()

    # src/linspace.jl line 92
    b = SVal(1.0)
    e = SVal(10.0)
    l = SVal(5)
    @test @inferred(linspace(b, e, l)) == StaticRanges.SRange{Float64,HPSVal{Float64,1.0,0.0},HPSVal{Float64,1.0,0.0},5.0,5,1}()

    # src/linlspace.jl line 139
    T = Float16
    b = SVal(1.0)
    e = SVal(1.0)
    l = SVal(1)
    @test @inferred(linspace1(T, b, e, l)) == StaticRanges.SRange{Float16,SVal{1.0,Float64},SVal{0.0,Float64},Float16(1.0),1,1}()

    # src/linspace.jl line 159
    @test @inferred(linrange(T,b,e,l)) == StaticRanges.SRange{Float16,SVal{1.0,Float64},SVal{0.0,Float64},Float16(1.0),1,1}()
end
