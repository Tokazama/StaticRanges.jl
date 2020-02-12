
@testset "promotion" begin
    for (mr,br,sr) in ((OneToMRange(10),         OneTo(10),              OneToSRange(10)),
                       (UnitMRange(1, 10),       UnitRange(1, 10),       UnitSRange(1, 10)),
                       (StepMRange(1, 1, 10),    StepRange(1, 1, 10),    StepSRange(1, 1, 10)),
                       (LinMRange(1, 10, 10),    LinRange(1, 10, 10),    LinSRange(1, 10, 10)),
                       (StepMRangeLen(1, 1, 10), StepRangeLen(1, 1, 10), StepSRangeLen(1, 1, 10))
                      )
        @testset "$(typeof(br)) lower range" begin
            @test last(promote(br, sr)) == br
            @test last(promote(sr, br)) == br
            @test last(promote(br, mr)) == mr
            @test last(promote(mr, br)) == mr
        end
        for (mr2,br2,sr2) in ((OneToMRange(10),         OneTo(10),              OneToSRange(10)),
                              (UnitMRange(1, 10),       UnitRange(1, 10),       UnitSRange(1, 10)),
                              (StepMRange(1, 1, 10),    StepRange(1, 1, 10),    StepSRange(1, 1, 10)),
                              (LinMRange(1, 10, 10),    LinRange(1, 10, 10),    LinSRange(1, 10, 10)),
                              (StepMRangeLen(1, 1, 10), StepRangeLen(1, 1, 10), StepSRangeLen(1, 1, 10))
                             )
            if br != br2
                @testset "$(typeof(br)) & $(typeof(br2))" begin
                    br3 = last(promote(br, br2))
                    @test eltype(last(promote(mr, mr2))) == eltype(br3)
                    @test eltype(last(promote(mr2, mr))) == eltype(br3)

                    @test eltype(last(promote(sr, sr2))) == eltype(br3)
                    @test eltype(last(promote(sr2, sr))) == eltype(br3)
                end
            end
        end
    end
    @testset "promote_rule" begin
        for (t1,t2,p) in ((OneToMRange{Int}, OneToSRange{Int,10}, OneToMRange{Int}),
                          (OneToMRange{Int}, OneTo{Int}, OneToMRange{Int}),
                          (OneToMRange{Int}, OneTo{Int}, OneToMRange{Int}),
                          (OneToSRange{Int,10}, OneTo{Int}, OneTo{Int}),

                          (UnitMRange{Int}, UnitSRange{Int,1,10}, UnitMRange{Int}),
                          (UnitMRange{Int}, UnitRange{Int}, UnitMRange{Int}),
                          (UnitMRange{Int}, UnitRange{Int}, UnitMRange{Int}),
                          (UnitSRange{Int,1,10}, UnitRange{Int}, UnitRange{Int}),

                          (StepMRange{Int,Int}, StepSRange{Int,Int,1,1,10}, StepMRange{Int,Int}),
                          (StepMRange{Int,Int}, StepRange{Int,Int}, StepMRange{Int,Int}),
                          (StepMRange{Int,Int}, StepRange{Int,Int}, StepMRange{Int,Int}),
                          (StepSRange{Int,Int,1,1,10}, StepRange{Int,Int}, StepRange{Int,Int}),

                          (LinMRange{Int}, LinSRange{Int,1,10,10,9}, LinMRange{Int}),
                          (LinMRange{Int}, LinRange{Int}, LinMRange{Int}),
                          (LinMRange{Int}, LinRange{Int}, LinMRange{Int}),
                          (LinSRange{Int,1,10,10,9}, LinRange{Int}, LinRange{Int}),

                          (StepMRangeLen{Int,Int,Int}, StepSRangeLen{Int,Int,Int,1,1,10,1}, StepMRangeLen{Int,Int,Int}),
                          (StepMRangeLen{Int,Int,Int}, StepRangeLen{Int,Int,Int}, StepMRangeLen{Int,Int,Int}),
                          (StepMRangeLen{Int,Int,Int}, StepRangeLen{Int,Int,Int}, StepMRangeLen{Int,Int,Int}),
                          (StepSRangeLen{Int,Int,Int,1,1,10,1}, StepRangeLen{Int,Int,Int}, StepRangeLen{Int,Int,Int}),

                          (OneToMRange{Int}, LinSRange{Int,1,10,10,9}, LinMRange{Int}),
                          (OneToMRange{Int}, UnitSRange{Int,1,10}, UnitMRange{Int}),
                          (OneToMRange{Int}, StepSRangeLen{Int,Int,Int,1,1,10,1}, StepMRangeLen{Int,Int,Int}),
                         )
            @testset "$t1 + $t2" begin
                @test (@inferred(promote_rule(t1, t2)) <: p) == true
                @test (@inferred(promote_rule(t2, t1)) <: p) == true
            end
        end
    end
end
