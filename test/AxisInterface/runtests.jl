
struct Axis2{K,V,Ks,Vs} <: AbstractAxis{K,V,Ks,Vs}
    keys::Ks
    values::Vs
end

Axis2(ks, vs) = Axis2{eltype(ks),eltype(vs),typeof(ks),typeof(vs)}(ks, vs)
Base.keys(a::Axis2) = getfield(a, :keys)
Base.values(a::Axis2) = getfield(a, :values)



@test_throws ErrorException StaticRanges.unsafe_reindex(Axis2(1:2, 1:2), 1:2)

@testset "array interface" begin
    a1 = Axis(2:3, 1:2)

    @test first(a1) == 1
    @test last(a1) == 2
    @test sum(a1) == 3
    @test haskey(a1, 3)
    @test !haskey(a1, 4)
    @test allunique(a1)
    @test in(2, a1)
    @test !in(3, a1)
    @test checkbounds(Bool, a1, CartesianIndex(1))
    @test !checkbounds(Bool, a1, CartesianIndex(5))
    # TODO test checkbounds by key indexing
    @test values_type(a1) <: UnitRange{Int64}
end

@testset "resize tests" begin
    x = 1:10
    @test resize_last!(x, 10) == x
    @test resize_last(x, 10) == x

end

include("range_tests.jl")
include("reduce.jl")
include("promotions.jl")
include("axisindices_tests.jl")
include("indexing.jl")

@testset "next_type" begin
    @test next_type("a") == "b"
    @test next_type(:a) == :b
    @test next_type('a') == 'b'
    @test next_type(1) == 2
    @test next_type(1.0) == nextfloat(1.0)
    @test next_type("") == ""
end

@testset "prev_type" begin
    @test prev_type("b") == "a"
    @test prev_type(:b) == :a
    @test prev_type('b') == 'a'
    @test prev_type(1) == 0
    @test prev_type(nextfloat(1.0)) == prevfloat(nextfloat(1.0))
    @test prev_type("") == ""
end
