
@testset "Range Interface" begin
    for r in (OneToMRange(10),
              as_dynamic(1:10),
              MutableRange(StepRangeLen(1, 1, 10)))
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
        end
    end
end
