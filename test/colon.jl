@testset "colon" begin
    #@inferred((:)(10, 1, 0))
    @inferred(srange(Val(10), step=Val(1), stop=Val(0)))

    #@inferred((:)(1, .2, 2))
    @inferred(srange(Val(1), step=Val(.2), stop=Val(2)))

    #@inferred((:)(1., .2, 2.))
    @inferred(srange(Val(1.), step=Val(.2), stop=Val(2.)))

    #@inferred((:)(2, -.2, 1))
    @inferred(srange(Val(2), step=Val(-.2), stop=Val(1)))

    #@inferred((:)(0.0, -0.5))
    @inferred(srange(Val(0.0), Val(-0.5)))

    #@inferred((:)(1, 0))
    @inferred(srange(Val(1),Val(0)))
end