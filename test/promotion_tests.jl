
@testset "promotion" begin
    for (mr,br) in ((OneToMRange(10),         OneTo(10)),)
        @testset "$(typeof(br)) lower range" begin
            @test last(promote(br, mr)) == mr
            @test last(promote(mr, br)) == mr
        end
        for (mr2,br2) in ((OneToMRange(10),         OneTo(10)),
                             )
            if br != br2
                @testset "$(typeof(br)) & $(typeof(br2))" begin
                    br3 = last(promote(br, br2))
                    @test eltype(last(promote(mr, mr2))) == eltype(br3)
                    @test eltype(last(promote(mr2, mr))) == eltype(br3)

                end
            end
        end
    end
    @testset "promote_rule" begin
        for (t1,t2,p) in ((OneToMRange{Int}, OneTo{Int}, OneToMRange{Int}),
                          (OneToMRange{Int}, OneTo{Int}, OneToMRange{Int}),
                         )
            @testset "$t1 + $t2" begin
                @test (@inferred(promote_rule(t1, t2)) <: p) == true
                @test (@inferred(promote_rule(t2, t1)) <: p) == true
            end
        end
    end
end
