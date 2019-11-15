@testset "Uniqueness" begin
    for (v,u) in ((1:10, AllUnique),
                  (collect(1:10), UnkownUnique),
                  (Vector{Int}, UnkownUnique),
                  (UnitRange{Int}, AllUnique)
                 )
        @test Uniqueness(v) === u
    end

    for (v,b) in ((1:10, true),
                  (collect(1:10), true),
                 )
        @test all_unique(v) == b
        @test all_unique(v, AllUnique) == true
    end

    struct Tmp end
    StaticRanges.Uniqueness(::Type{T}) where {T<:Tmp} = NotUnique

    @test_throws ErrorException all_unique(1:10, NotUnique)
    @test_throws ErrorException all_unique(Tmp(), AllUnique)
end
