
@testset "Range Interface" begin
    for r in (OneToMRange(10),
              OneToSRange(10),
              UnitMRange(1, 10),
              UnitSRange(1, 10),
              StepMRange(1, 1, 10),
              StepSRange(1, 1, 10),
              LinMRange(1, 10, 10),
              LinSRange(1, 10, 10),
              StepMRangeLen(1, 1, 10),
              StepSRangeLen(1, 1, 10)
             )
        @testset "$(typeof(r))" begin
            @testset "first" begin
                @test @inferred(first(r)) == 1
            end
            @testset "firstindex" begin
                @test @inferred(firstindex(r)) == 1
            end
            @testset "step" begin
                @test @inferred(step(r)) == 1
            end
            @testset "last" begin
                @test @inferred(last(r)) == 10
            end
            @testset "lastindex" begin
                @test @inferred(lastindex(r)) == 10
            end
            @testset "length" begin
                @test @inferred(length(r)) == 10
            end
            if r isa StaticRanges.AbstractStepRange
                @testset "start-property" begin
                    @test @inferred(getproperty(r, :start)) == 1
                end
                @testset "step-property" begin
                    @test @inferred(getproperty(r, :step)) == 1
                end
                @testset "stop-property" begin
                    @test @inferred(getproperty(r, :stop)) == 10
                end
            end

            if r isa StaticRanges.AbstractLinRange
                @testset "start-property" begin
                    @test getproperty(r, :start) == 1
                end
                @testset "stop-property" begin
                    @test getproperty(r, :stop) == 10
                end
                @testset "lendiv-property" begin
                    @test getproperty(r, :lendiv) == 9
                end
                @testset "len-property" begin
                    @test getproperty(r, :len) == 10
                end
            end
        end
    end
end
