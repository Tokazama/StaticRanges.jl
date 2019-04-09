@testset "findall(::Base.Fix2{typeof(in)}, ::Array)" begin
    @test findall(in(srange(3:20)), [5.2, 3.3]) == findall(in(Vector(srange(3:20))), [5.2, 3.3])

    let span = srange(5:20),
        r = srange(-7:3:42)
        @test findall(in(span), r) == srange(5:10)
        r = srange(15:-2:-38)
        @test findall(in(span), r) == srange(1:6)
    end
end

@testset "findfirst" begin
    @test findfirst(isequal(7), srange(1:2:10)) == 4
    @test findfirst(==(7), srange(1:2:10)) == 4
    @test findfirst(==(10), srange(1:2:10)) == nothing
    @test findfirst(==(11), srange(1:2:10)) == nothing
end

@testset "reverse" begin
    @test reverse(reverse(srange(1:10))) == srange(1:10)
    @test reverse(reverse(typemin(Int):typemax(Int))) == typemin(Int):typemax(Int)
    @test reverse(reverse(typemin(Int):2:typemax(Int))) == typemin(Int):2:typemax(Int)
end

@testset "sort/sort!/partialsort" begin
    @test sort(srange(1,2)) == srange(1,2)
    @test sort!(srange(1,2)) == srange(1,2)
    @test sort(srange(1:10), rev=true) == srange(10:-1:1)
    @test sort(srange(-3:3), by=abs) == [0,-1,1,-2,2,-3,3]
    @test partialsort(srange(1:10), 4) == 4
end
