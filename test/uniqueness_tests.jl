
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
                  (Vector{Int}, true),
                  (UnitRange{Int}, true)
                 )
        @test all_unique(v) == b
        @test all_unique(v, AllUnique) == true
        @test all_unique(v, NotUnique) == false
    end
end
