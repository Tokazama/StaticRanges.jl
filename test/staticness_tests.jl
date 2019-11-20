@testset "Staticness" begin
    # as_[mutable/immutable/static]
    for (i,m,s) in ((OneTo(4), OneToMRange(4), OneToSRange(4)),
                    (UnitRange(1, 3), UnitMRange(1, 3), UnitSRange(1, 3)),
                    (StepRange(1, 1, 4), StepMRange(1, 1, 4), StepSRange(1, 1, 4)),
                    (StepRangeLen(1, 1, 4), StepMRangeLen(1, 1, 4), StepSRangeLen(1, 1, 4)),
                    (LinRange(1, 4, 4), LinMRange(1, 4, 4), LinSRange(1, 4, 4)),
                   )
        @testset "as_dynamic($(typeof(i).name))" begin
            @test ismutable(as_dynamic(i)) == true
            @test ismutable(as_dynamic(m)) == true
            @test ismutable(as_dynamic(s)) == true
        end

        @testset "as_fixed($(typeof(i).name))" begin
            @test isimmutable(as_fixed(i)) == true
            @test isimmutable(as_fixed(m)) == true
            @test isimmutable(as_fixed(s)) == true
        end

        @testset "as_static($(typeof(i).name))" begin
            @test is_static(as_static(i)) == true
            @test is_static(as_static(m)) == true
            @test is_static(as_static(s)) == true
        end
    end
end
