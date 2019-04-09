@testset "indexing" begin
    L32 = @inferred(srange(Val(Int32(1)), stop=Val(Int32(4)), length=Val(4)))
    L64 = @inferred(srange(Val(Int64(1)), stop=Val(Int64(4)), length=Val(4)))
    @test @inferred(L32[1]) === 1.0 && @inferred(L64[1]) === 1.0
    @test L32[2] == 2 && L64[2] == 2
    @test L32[3] == 3 && L64[3] == 3
    @test L32[4] == 4 && L64[4] == 4

    @test @inferred(srange(Val(1.0), stop=Val(2.0), length=Val(2)))[1] === 1.0
    @test @inferred(srange(Val(1.0f0), stop=Val(2.0f0), length=Val(2)))[1] === 1.0f0
    @test @inferred(srange(Val(Float16(1.0)), stop=Val(Float16(2.0)), length=Val(2)))[1] === Float16(1.0)

    let r = srange(5:-1:1)
        @test r[1]==5
        @test r[2]==4
        @test r[3]==3
        @test r[4]==2
        @test r[5]==1
    end
    @test @inferred(srange(Val(0.1), step=Val(0.1), stop=Val(0.3))[2]) === 0.2
    @test @inferred(srange(Val(0.1f0), step=Val(0.1f0), stop=Val(0.3f0))[2]) === 0.2f0

    @test @inferred(srange(Val(1), stop=Val(5))[srange(Val(1), stop=Val(4))]) === srange(1:4)
    @test @inferred(srange(Val(1.0), stop=Val(5))[srange(Val(1), stop=Val(4))]) === srange(1.0:4)
    @test srange(2:6)[1:4] == srange(2:5)
    @test srange(1:6)[2:5] === srange(2:5)
    @test srange(1:6)[2:2:5] === srange(2:2:4)
    @test srange(1:2:13)[2:6] === srange(3:2:11)
    @test srange(1:2:13)[2:3:7] === srange(3:6:13)

    #@test isempty(srange(1:4)[5:4])
    @test_throws BoundsError srange(1:10)[8:-1:-2]

    let r = srange(typemax(Int)-5:typemax(Int)-1)
        @test_throws BoundsError r[7]
    end
end
