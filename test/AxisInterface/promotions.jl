@testset "AbstractAxis promotions" begin
    a1 = Axis(1:10)
    a2 = Axis(1.0:10.0)
    sa1 = SimpleAxis(1:10)
    sa2 = SimpleAxis(UnitRange(UInt(1), UInt(10)))
    @test Base.promote_rule(typeof(a1), typeof(a2)) <: Axis{Float64,Int64,StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}},Base.OneTo{Int64}}
    @test Base.promote_rule(typeof(a2), typeof(a1)) <: Axis{Float64,Int64,StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}},Base.OneTo{Int64}}

    @test Base.promote_rule(typeof(a1), typeof(sa1)) <: Axis{Int64,Int64,UnitRange{Int64},UnitRange{Int64}}
    @test Base.promote_rule(typeof(sa1), typeof(a1)) <: Axis{Int64,Int64,UnitRange{Int64},UnitRange{Int64}}

    @test Base.promote_rule(typeof(a2), typeof(sa1)) <: Axis{Float64,Int64,StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}},UnitRange{Int64}}
    @test Base.promote_rule(typeof(sa1), typeof(a2)) <: Axis{Float64,Int64,StepRangeLen{Float64,Base.TwicePrecision{Float64},Base.TwicePrecision{Float64}},UnitRange{Int64}}

    @test Base.promote_rule(typeof(sa1), typeof(sa2)) <: SimpleAxis{UInt,UnitRange{UInt}}
    @test Base.promote_rule(typeof(sa2), typeof(sa1)) <: SimpleAxis{UInt,UnitRange{UInt}}


    @test Base.promote_rule(typeof(sa2), typeof(1:10)) <: UnitRange{UInt}
    @test Base.promote_rule(typeof(1:10), typeof(sa2)) <: UnitRange{UInt}

    for (x,y,T) in ((Axis(1:2), Axis(1:2), Axis),
                    (SimpleAxis(1:2), Axis(1:2), Axis),
                    (SimpleAxis(1:2), SimpleAxis(1:2), SimpleAxis),
                    (Axis(1:2), Axis2(1:2,1:2), Axis),
                    (SimpleAxis(1:2), Axis2(1:2,1:2), SimpleAxis),
                   )
        @test StaticRanges.promote_axis_rule(x, y) == T
        @test StaticRanges.promote_axis_rule(y, x) == T
    end
    
end
