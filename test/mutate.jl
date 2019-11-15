@testset "Mutable interface" begin

    @testset "can_set_first" begin
        @test @inferred(can_set_first(LinRange)) == false
        @test @inferred(can_set_first(LinMRange)) == true
        @test @inferred(can_set_first(StepMRange)) == true
        @test @inferred(can_set_first(UnitMRange)) == true
        @test @inferred(can_set_first(StepMRangeLen)) == true
    end

    @testset "can_set_last" begin
        @test @inferred(can_set_last(LinRange)) == false
        @test @inferred(can_set_last(LinMRange)) == true
        @test @inferred(can_set_last(StepMRange)) == true
        @test @inferred(can_set_last(StepMRangeLen)) == true
        @test @inferred(can_set_last(UnitMRange)) == true
        @test @inferred(can_set_last(OneToMRange)) == true
    end

    @testset "can_set_step" begin
        @test @inferred(can_set_step(LinRange)) == false
        @test @inferred(can_set_step(LinMRange)) == false
        @test @inferred(can_set_step(StepMRange)) == true
        @test @inferred(can_set_step(StepMRangeLen)) == true
    end

    for (r1,b,v,r2) in ((UnitMRange(1,3), true, 2, UnitMRange(2,3)),
                        (StepMRange(1,1,4), true, 2, StepMRange(2,1,4)),
                        (StepSRange(1,1,4), false, nothing, nothing),
                        (LinMRange(1,3,3), true, 2, LinMRange(2,3,3)),
                        (StepMRangeLen(1,1,3), true, 2, StepMRangeLen(2,1,3)),
                        (StepSRangeLen(1,1,3), false, nothing, nothing),
                        ([1,2,3], true, 2, [2,2,3]))
        @testset "set_first-$(r1)" begin
            x = @inferred(can_set_first(r1))
            @test x == b
            if x
                set_first!(r1, v)
                @test r1 == r2
            end
        end
    end

    for (r1,b,v,r2) in ((UnitMRange(1,3), true, 5, UnitMRange(1,5)),
                        (OneToMRange(4), true, 5, OneToMRange(5)),
                        (OneToMRange(4), true, Int32(5), OneToMRange(5)),
                        (StepMRange(1,1,4), true, 5, StepMRange(1,1,5)),
                        (StepSRange(1,1,4), false, nothing, nothing),
                        (LinMRange(1,3,3), true, 4, LinMRange(1,4,3)),
                        (StepMRangeLen(1,1,3), true, 4, StepMRangeLen(1,1,4)),
                        ([1,2,3], true, 2, [1,2,2]))
        @testset "set_last-$(r1)" begin
            x = @inferred(can_set_last(r1))
            @test x == b
            if x
                @test @inferred(set_last!(r1, v)) == r2
            end
        end
    end

    @testset "set_step!" begin
        @testset "has_step" begin
            @test @inferred(has_step(OneToMRange{Int})) == true
            @test @inferred(has_step([])) == false
            @test @inferred(has_step(Vector)) == false
        end
        @test_throws ErrorException set_step!(OneToMRange(10), 2)
        @test_throws ErrorException set_step!(UnitMRange(1, 10), 2)


        for (r1,b,v,r2) in ((UnitMRange(1,3), false, nothing, nothing),
                            (StepMRange(1,1,4), true, 2, StepMRange(1,2,4)),
                            (StepMRange(1,1,4), true, UInt32(2), StepMRange(1,2,4)),
                            (StepMRangeLen(1,1,4), true, 2, StepMRangeLen(1,2,4)),
                           )

            @testset "set_step!-$(r1)" begin
                x = @inferred(can_set_step(r1))
                @test x == b
                if x
                    @test @inferred(set_step!(r1, v)) == r2
                end
            end
        end
    end

    @testset "set_ref!" begin
        @test @inferred(set_ref!(StepMRangeLen(1, 1, 10), 2)) == StepMRangeLen(2, 1, 10)
        @test @inferred(set_ref!(StepMRangeLen(1, 1, 10), UInt32(2))) == StepMRangeLen(2, 1, 10)
    end

    @testset "set_offset!" begin
        @test @inferred(set_offset!(StepMRangeLen(1, 1, 10), 2)) == StepMRangeLen(1, 1, 10, 2)
        @test @inferred(set_offset!(StepMRangeLen(1, 1, 10), UInt32(2))) == StepMRangeLen(1, 1, 10, 2)
    end

    @testset "is_static" begin
        @test @inferred(is_static(Any[])) == false
        @test @inferred(is_static(UnitSRange(1, 10))) == true
    end

    #= TODO as_[mutable/immutable/static]
    as_mutable(x::OneToMRange) = x
    as_mutable(x::Union{OneTo,OneToSRange}) = OneToMRange(last(x))
    as_mutable(x::UnitMRange) = x
    as_mutable(x::Union{UnitRange,UnitSRange}) = UnitMRange(first(x), last(x))
    as_mutable(x::StepMRange) = x
    as_mutable(x::Union{StepRange,StepSRange}) = StepMRange(first(x), step(x), last(x))
    as_mutable(x::LinMRange) = x
    as_mutable(x::Union{LinRange,LinSRange}) = LinMRange(first(x), last(x), length(x))
    as_mutable(x::StepMRangeLen) = x
    as_mutable(x::Union{StepRangeLen,StepSRangeLen}) = S
    as_mutable(r)
    as_immutable(r)
    as_static(r)
    =#
end
