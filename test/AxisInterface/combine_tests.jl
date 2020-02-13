@testset "combine" begin
    for (v1,v2,v3) in ((OneTo(10), OneTo(9), OneTo(10)),
                       (OneTo(10), 11:15, OneTo(15)),
                       (OneTo(10), 10:15, OneTo(15)),
                       (OneTo(10), 9:15, OneTo(15)),
                       (OneTo(10), -1:15, -1:15),
                       (OneTo(10), 2:9, 1:10),
                       (OneTo(10), 12:15, vcat(OneTo(10), 12:15)),
                       (OneTo(10), 1.5:10.5, sort(vcat(OneTo(10), 1.5:10.5))),
                       (1:5, 1:5, 1:5),
                       (1:6, 4:10, 1:10),
                       (1:5, 6:10, 1:10),
                       (1:5, 7:10, vcat(1:5, 7:10)),
                       (1:7, 6:10, 1:10),
                       (1:11, 6:10, 1:11),
                       (1:1:10, 1:1:9, 1:1:10),
                       (1:1.5:10, 1:1:9, sort(vcat(1:1.5:10, 1:1:10))),
                      )

        @testset "$(v1)-$(v2)" begin
            @test combine(v1, v2) == v3
            @test combine(v2, v1) == v3
        end
        rv1 = reverse(v1)
        @testset "$(rv1)-$(v2)" begin
            @test combine(rv1, v2) == reverse(v3)
            @test combine(v2, rv1) == combine(v2, reverse(rv1))
        end
        #=
        @testset "$(v4)-$(v5)" begin
            @test combine(v4, v5) == v6
            @test combine(v4, v5) == v6
        end
        =#
    end
end
