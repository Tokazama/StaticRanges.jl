using StaticRanges.StaticValues: twiceprecision

@testset "twiceprecision" begin
    hp = HPSVal{Float64,1.0,0.0}()
    nb = SVal(1)
    @test @inferred(twiceprecision(hp, nb)) == HPSVal{Float64,1.0,0.0}()

    v = SVal(1.0)
    @test @inferred(twiceprecision(v, nb)) == HPSVal{Float64,1.0,0.0}()
end