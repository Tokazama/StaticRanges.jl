using Base: TwicePrecision
using StaticRanges: TPVal

@testset "twice precision" begin
    tp = TwicePrecision(1)

    @test TPVal(tp) == TPVal{Int,1,0}()
    @test TwicePrecision(TPVal(tp)) == tp
    @test TPVal{Int}(tp) == TPVal{Int,1,0}()
    @test TPVal{Float64}(tp) == TPVal{Float64,1.0,0.0}()

    tpval = TPVal(tp)

    @test eltype(tpval) == eltype(tp)
    @test eltype(typeof(tpval)) == eltype(tp)

    @test StaticRanges.tp2val(1) == 1
    @test StaticRanges.tp2val(tp) == tpval
    @test Int(tpval) == Int(tp)
    @test convert(Int, tpval) == Int(tp)
end
