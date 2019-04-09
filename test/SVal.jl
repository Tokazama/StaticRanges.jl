

@testset "SVal" begin
    @testset "SVal Constructors" begin
        SVal(1) == SVal{1,Int}()
        SVal{1}() == SVal{1,Int}()
        SVal(Sval{1}) == SVal{1,Int}()
        SVal(SVal(1)) == SVal{1,Int}()
        SFloat64(1) == SVal{1.0,Float64}()
    end

    @testset "SVal math" begin
    end
end
