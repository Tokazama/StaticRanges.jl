@testset "broadcast" begin
    for (mr,br,sr) in ((OneToMRange(10),         OneTo(10),              OneToSRange(10)),
                       (UnitMRange(1, 10),       UnitRange(1, 10),       UnitSRange(1, 10)),
                       (StepMRange(1, 1, 10),    StepRange(1, 1, 10),    StepSRange(1, 1, 10)),
                       (LinMRange(1, 10, 10),    LinRange(1, 10, 10),    LinSRange(1, 10, 10)),
                       (StepMRangeLen(1, 1, 10), StepRangeLen(1, 1, 10), StepSRangeLen(1, 1, 10))
                      )
        @test broadcast(+, mr) == broadcast(+, sr) == broadcast(+, br)
        @test broadcast(-, mr) == broadcast(-, sr) == broadcast(-, br)

        @test broadcast(+, 1, mr) == broadcast(+, 1, sr) == broadcast(+, 1, br)
        @test broadcast(-, 1, mr) == broadcast(-, 1, sr) == broadcast(-, 1, br)

        @test broadcast(+, mr, 1) == broadcast(+, sr, 1) == broadcast(+, br, 1)
        @test broadcast(-, mr, 1) == broadcast(-, sr, 1) == broadcast(-, br, 1)

        @test broadcast(*, 1, mr) == broadcast(*, 1, sr) == broadcast(*, 1, br)
        @test broadcast(*, mr, 1) == broadcast(*, sr, 1) == broadcast(*, br, 1)

        @test broadcast(\, 1, mr) == broadcast(\, 1, sr) == broadcast(\, 1, br)
    end
end
