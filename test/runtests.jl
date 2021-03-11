
using StaticArrays
using Test, StaticRanges, Dates, Documenter, IntervalSets

using StaticRanges: grow_beg, grow_beg!, grow_end, grow_end!,
    shrink_beg, shrink_beg!, shrink_end, shrink_end!

using ChainedFixes
using OffsetArrays
using OffsetArrays: IdOffsetRange

using ArrayInterface
using ArrayInterface: can_change_size, known_first, known_last, known_step, axes_types
using ArrayInterface.Static

# Uniqueness methods
using StaticRanges: ArrayInterface.ismutable

using Base: OneTo, step_hp

catch_nothing(x) = x
catch_nothing(x::Nothing) = 0


#@test isempty(setdiff(detect_ambiguities(StaticRanges,Base,Core), detect_ambiguities(StaticArrays,Base,Core)))

#=
When using ranges find_all will produce either an AbstractUnitRange or GapRange.
Therefore, in order test type stability at this level we just ensure it only ever
comes down to one of these two types and convert them to Vector.
=#
to_vec(x::AbstractUnitRange{Int}) = collect(x)
to_vec(x::GapRange) = collect(x)
to_vec(x) = x

@test StaticRanges.ArrayInterface.ismutable(OneToMRange(10))

@testset "checkindex" begin
    r = 1:5
    all_inbounds = 1:5
    top_outbounds = 1:6
    bottom_outbounds = 0:5
    @testset "checkindexlo" begin
        @test StaticRanges.checkindexlo(r, all_inbounds)
        @test StaticRanges.checkindexlo(r, top_outbounds)
        @test !StaticRanges.checkindexlo(r, bottom_outbounds)
        @test StaticRanges.checkindexlo(r, CartesianIndex((1,)))
    end

    @testset "checkindexhi" begin
        @test StaticRanges.checkindexhi(r, all_inbounds)
        @test !StaticRanges.checkindexhi(r, top_outbounds)
        @test StaticRanges.checkindexhi(r, bottom_outbounds)
        @test StaticRanges.checkindexhi(r, CartesianIndex((1,)))
    end
end

include("length_tests.jl")
include("find.jl")
include("gaprange_tests.jl")

include("promotion_tests.jl")
# FIXME include("nitty_gritty_promotion.jl")

@test first(GapRange(2:5, 7:10)) == 2
@test last(GapRange(2:5, 7:10)) == 10

include("range_interface.jl")
include("broadcast.jl")
include("onetorange.jl")
include("intersect_tests.jl")


@testset "empty" begin
    for r in (static(OneTo(10)),
              OneToMRange(10),
              srange(1.0, step=1, stop=10.0),
              mrange(1.0, step=1, stop=10.0),
              static(StepRange(1, 1, 10)),
              static(UnitRange(1, 10)),
              static(LinRange(1.5, 5.5, 9)))
        @test isempty(empty(r))
        if can_change_size(r)
            empty!(r)
            @test isempty(r)
        end
    end
end

#=
@testset "UnitRange" begin
    r = MutableRange(1:10)
    b = UnitRange(1, 10)
    rfloat = AbstractUnitRange{Float64}(r)
    @test eltype(rfloat) == Float64
    @test isa(rfloat, R)
    @test R{Int}(r) == r  # we don't use `===` because dynamic ranges should construct different ones
    @test R{Float64}(r) == R(1., 10.)
    @test eltype(R{Int}(UnitRange(UInt(1), UInt(10)))) == Int
    @test R(UnitRange(UInt(1), UInt(10))) == R(UInt(1), UInt(10))
    @test first(r) == r.start
    @test last(r) == r.stop

    @test intersect(r, r[2]) == intersect(b, b[2])
    @test intersect(r, r[2]) == intersect(b, b[2])

    @test @inferred(getindex(UnitMRange(1.0, 10.0), 2)) == 2.0

    @test_throws ErrorException r.notfield
    #=
    setproperty!(r, :start, 2)
    @test r == UnitMRange(2, 10)

    setproperty!(r, :stop, 8)
    @test r == UnitMRange(2, 8)

    @test_throws ErrorException setproperty!(r, :anything, 3)
    =#
end
=#

for frange in (mrange, srange)
    @testset "$frange" begin
        @test_throws ArgumentError frange(1)
        @test_throws ArgumentError frange(1, step=1)
        @test_throws ArgumentError frange(nothing)
        @test_throws ArgumentError frange(nothing, length=1)
        @test_throws ArgumentError frange(1, step=1, stop=1, length=1)
        if frange == mrange
            # cannot infer a static parameter from construction
            @testset "colon" begin
                @inferred(frange(10, step=1, stop=0))
                @inferred(frange(1, step=.2, stop=2))
                @inferred(frange(1., step=.2, stop=2.))
                @inferred(frange(2, step=-.2, stop=1))
                @inferred(frange(1, 0))
                @inferred(frange(0.0, -0.5))
            end
        end
        @testset "indexing" begin
            L32 = frange(Int32(1), stop=Int32(4), length=4)
            L64 = frange(Int64(1), stop=Int64(4), length=4)
            @test @inferred(L32[1]) === 1.0 && @inferred(L64[1]) === 1.0
            @test L32[2] == 2 && L64[2] == 2
            @test L32[3] == 3 && L64[3] == 3
            @test L32[4] == 4 && L64[4] == 4
            @test frange(1.0, stop=2.0, length=2)[1] === 1.0
            @test frange(1.0f0, stop=2.0f0, length=2)[1] === 1.0f0
            @test frange(Float16(1.0), stop=Float16(2.0), length=2)[1] === Float16(1.0)

            let r = frange(5, step=-1, stop=1)
                @test r[1]==5
                @test r[2]==4
                @test r[3]==3
                @test r[4]==2
                @test r[5]==1
            end
            @test @inferred(frange(0.1, step=0.1, stop=0.3)[2]) === 0.2
            @test @inferred(frange(0.1f0, step=0.1f0, stop=0.3f0)[2]) === 0.2f0

            @test frange(1, 5)[1:4] == 1:4
            @test frange(1.0, 5)[1:4] == 1.0:4
            @test frange(2, 6)[1:4] == 2:5
            @test frange(1, 6)[2:5] == 2:5
            @test frange(1, 6)[2:2:5] == 2:2:4
            @test frange(1, step=2, stop=13)[2:6] == 3:2:11
            @test frange(1, step=2, stop=13)[2:3:7] == 3:6:13

            @test isempty(frange(1, 4)[5:4])
            #@test_throws BoundsError frange(1:10)[8:-1:-2]
        end
       @testset "keys/values" begin
            keytype_is_correct(r) = keytype(r) == eltype(keys(r))
            valtype_is_correct(r) = valtype(r) == eltype(values(r))
            @test keytype_is_correct(frange(1, 3))
            @test keytype_is_correct(frange(1, step=.3, stop=4))
            @test keytype_is_correct(frange(.11, step=.1, stop=.3))
            @test keytype_is_correct(frange(Int8(1), Int8(5)))
            @test keytype_is_correct(frange(Int16(1), Int8(5)))
            @test keytype_is_correct(frange(Int16(1), step=Int8(3), stop=Int8(5)))
            @test keytype_is_correct(frange(Int8(1), step=Int16(3), stop=Int8(5)))
            @test keytype_is_correct(frange(Int8(1), step=Int8(3), stop=Int16(5)))
            @test keytype_is_correct(frange(Int64(1), Int64(5)))
            @test keytype_is_correct(frange(Int64(1), Int64(5)))
            @test keytype_is_correct(frange(Int128(1), Int128(5)))
            @test valtype_is_correct(1:3)
            @test valtype_is_correct(1:.3:4)
            @test valtype_is_correct(.1:.1:.3)
            @test valtype_is_correct(frange(Int8(1), Int8(5)))
            @test valtype_is_correct(frange(Int16(1), Int8(5)))
            @test valtype_is_correct(frange(Int16(1), step=Int8(3), stop=Int8(5)))
            @test valtype_is_correct(frange(Int8(1), step=Int16(3), stop=Int8(5)))
            @test valtype_is_correct(frange(Int8(1), step=Int8(3), stop=Int16(5)))
            @test valtype_is_correct(frange(Int64(1), Int64(5)))
            @test valtype_is_correct(frange(Int64(1), Int64(5)))
            @test valtype_is_correct(frange(Int128(1), Int128(5)))

            if frange isa typeof(mrange)
                @test keytype_is_correct(OneToMRange(4))
                @test keytype_is_correct(OneToMRange(Int32(4)))
                @test valtype_is_correct(OneToMRange(4))
                @test valtype_is_correct(OneToMRange(Int32(4)))
            else
                @test keytype_is_correct(static(OneTo((4))))
                @test keytype_is_correct(static(OneTo((Int32(4)))))
                @test valtype_is_correct(static(OneTo((4))))
                @test valtype_is_correct(static(OneTo((Int32(4)))))
            end
        end

        @testset "findall(::Base.Fix2{typeof(in)}, ::Array)" begin
            @test findall(in(3:20), [5.2, 3.3]) == findall(in(Vector(3:20)), [5.2, 3.3])

            let span = frange(5, 20),
                r = frange(-7, step=3, stop=42)
                @test findall(in(span), r) == 5:10

                r = frange(15, step=-2, stop=-38)
                @test findall(in(span), r) == 1:6
            end
        end

        if VERSION > v"1.2"
            @testset "issubset" begin
                @test issubset(frange(1, 3), 1:typemax(Int)) #32461
                @test issubset(frange(1, 3), 1:3)
                @test issubset(frange(1, 3), 1:4)
                @test issubset(frange(1, 3), 0:3)
                @test issubset(frange(1, 3), 0:4)
                @test !issubset(frange(1, 5), 2:5)
                @test !issubset(frange(1, 5), 1:4)
                @test !issubset(frange(1, 5), 2:4)
                @test issubset(frange(1, step=3, stop=10), 1:10)
                @test !issubset(frange(1, 10), 1:3:10)

                @test issubset(1:3, frange(1, typemax(Int))) #32461
                @test issubset(1:3, frange(1, 3))
                @test issubset(1:3, frange(1, 4))
                @test issubset(1:3, frange(0, 3))
                @test issubset(1:3, frange(0, 4))
                @test !issubset(1:5, frange(2, 5))
                @test !issubset(1:5, frange(1, 4))
                @test !issubset(1:5, frange(2, 4))
                @test issubset(1:3:10, frange(1, 10))
                @test !issubset(1:10, frange(1, step=3, stop=10))
                if frange isa typeof(mrange)
                    @test issubset(OneToMRange(5), OneToMRange(10))
                    @test !issubset(OneToMRange(10), OneToMRange(5))
                    @test issubset(OneToMRange(5), OneToMRange(10))
                    @test !issubset(OneToMRange(10), OneToMRange(5))
                else
                    @test issubset(static(OneTo(5)), static(OneTo((10))))
                    @test !issubset(static(OneTo(10)), static(OneTo((5))))
                    @test issubset(static(OneTo(5)), static(OneTo((10))))
                    @test !issubset(static(OneTo(10)), static(OneTo((5))))
                end
 
            end
        end

        @testset "in" begin
            @test 0 in frange(UInt(0), step=100, stop=typemax(UInt))
            @test last(frange(UInt(0), step=100, stop=typemax(UInt))) in frange(UInt(0), step=100, stop=typemax(UInt))
            @test -9223372036854775790 in frange(-9223372036854775790, step=100, stop=9223372036854775710)
            @test -9223372036854775690 in frange(-9223372036854775790, step=100, stop=9223372036854775710)
            @test -90 in frange(-9223372036854775790, step=100, stop=9223372036854775710)
            @test 10 in frange(-9223372036854775790, step=100, stop=9223372036854775710)
            @test 110 in frange(-9223372036854775790, step=100, stop=9223372036854775710)
            @test 9223372036854775610 in frange(-9223372036854775790, step=100, stop=9223372036854775710)
            @test 9223372036854775710 in frange(-9223372036854775790, step=100, stop=9223372036854775710)

            @test !(3.5 in frange(1, 5))
            @test (3 in frange(1, 5))
            @test (3 in frange(5, step=-1, stop=1))
            #@test (3 in 3+0*(1:5))
            #@test !(4 in 3+0*(1:5))

            let r = frange(0.0, step=0.01, stop=1.0)
                @test (r[30] in r)
            end
            let r = frange((-4*Int64(maxintfloat(Int === Int32 ? Float32 : Float64))), 5)
                @test (3 in r)
                @test (3.0 in r)
            end

            @test !(1 in frange(1, 0))
            @test !(1.0 in frange(1.0, 0.0))
        end

        @testset "in() works across types, including non-numeric types (#21728)" begin
            @test 1//1 in frange(1, 3)
            @test 1//1 in frange(1.0, 3.0)
            @test !(5//1 in frange(1, 3))
            @test !(5//1 in frange(1.0, 3.0))
            @test Complex(1, 0) in frange(1, 3)
            @test Complex(1, 0) in frange(1.0, 3.0)
            @test Complex(1.0, 0.0) in frange(1, 3)
            @test Complex(1.0, 0.0) in frange(1.0, 3.0)
            @test !(Complex(1, 1) in frange(1, 3))
            @test !(Complex(1, 1) in frange(1.0, 3.0))
            @test !(Complex(1.0, 1.0) in frange(1, 3))
            @test !(Complex(1.0, 1.0) in frange(1.0, 3.0))
            @test !(π in frange(1, 3))
            @test !(π in frange(1.0, 3.0))
            @test !("a" in frange(1, 3))
            @test !("a" in frange(1.0, 3.0))
            @test !(1 in frange(Date(2017, 01, 01), step=Dates.Day(1), stop=Date(2017, 01, 05)))
            @test !(Complex(1, 0) in frange(Date(2017, 01, 01), step=Dates.Day(1), stop=Date(2017, 01, 05)))
            @test !(π in frange(Date(2017, 01, 01), step=Dates.Day(1), stop=Date(2017, 01, 05)))
            @test !("a" in frange(Date(2017, 01, 01), step=Dates.Day(1), stop=Date(2017, 01, 05)))
        end
        @testset "sums of ranges" begin
            @test sum(frange(1, 100)) == 5050
            @test sum(frange(0, 100)) == 5050
            @test sum(frange(-100, 100)) == 0
            @test sum(frange(0, step=2, stop=100)) == 2550
        end
        @testset "Tricky sums of StepRangeLen #8272" begin
            @test sum(frange(10000., step=-0.0001, stop=0)) == 5.00000005e11
            @test sum(frange(0, step=0.001, stop=1)) == 500.5
            @test sum(frange(0, step=0.000001, stop=1)) == 500000.5
            @test sum(frange(0, step=0.1, stop=10)) == 505.
        end
        @testset "operations between ranges and arrays" begin
            @test all(([frange(1, 5);] + (frange(5, step=-1, stop=1))) .== 6)
            @test all(((frange(5, step=-1, stop=1)) + [frange(1, 5);]) .== 6)
            @test all(([frange(1, 5);] - (frange(1, 5))) .== 0)
            @test all((frange(1, 5) - [frange(1, 5);]) .== 0)
        end

        @testset "broadcasted operations with scalars" begin
            @test broadcast(-, frange(1, 3)) == -1:-1:-3
            @test broadcast(-, frange(1, 3), 2) == -1:1
            @test broadcast(-, frange(1, 3), 0.25) == 1-0.25:3-0.25
            @test broadcast(+, frange(1, 3)) == 1:3
            @test broadcast(+, frange(1, 3), 2) == 3:5
            @test broadcast(+, frange(1, 3), 0.25) == 1+0.25:3+0.25
            @test broadcast(+, frange(1, step=2, stop=6), 1) == 2:2:6
            @test broadcast(+, frange(1, step=2, stop=6), 0.3) == 1+0.3:2:5+0.3
            @test broadcast(-, frange(1, step=2, stop=6), 1) == 0:2:4
            @test broadcast(-, frange(1, step=2, stop=6), 0.3) == 1-0.3:2:5-0.3
            @test broadcast(-, 2, frange(1, 3)) == 1:-1:-1
        end

        @testset "loops involving typemin/typemax" begin
            n = 0
            s = 0
            # loops ending at typemax(Int)
            for i = frange((typemax(Int)-1), typemax(Int))
                s += 1
                @test s <= 2
            end
            @test s == 2

            s = 0
            for i = frange((typemax(Int)-2), (typemax(Int)-1))
                s += 1
                @test s <= 2
            end
            @test s == 2

            s = 0
            for i = frange(typemin(Int), (typemin(Int)+1))
                s += 1
                @test s <= 2
            end
            @test s == 2

            # loops covering the full range of integers
            s = 0
            for i = frange(typemin(UInt8), typemax(UInt8))
                s += 1
            end
            @test s == 256

            s = 0
            for i = frange(typemin(UInt), typemax(UInt))
                i == 10 && break
                s += 1
            end
            @test s == 10

            s = 0
            for i = frange(typemin(UInt8), step=one(UInt8), stop=typemax(UInt8))
                s += 1
            end
            @test s == 256

            s = 0
            for i = frange(typemin(UInt), step=1, stop=typemax(UInt))
                i == 10 && break
                s += 1
            end
            @test s == 10

            # loops past typemax(Int)
            n = 0
            s = Int128(0)
            for i = frange(typemax(UInt64)-2, typemax(UInt64))
                n += 1
                s += i
            end
            @test n == 3
            @test s == 3*Int128(typemax(UInt64)) - 3

            # loops over empty ranges
            s = 0
            for i = 0xff:0x00
                s += 1
            end
            @test s == 0

            s = 0
            for i = frange(Int128(typemax(Int128)), Int128(typemin(Int128)))
                s += 1
            end
            @test s == 0
        end

        function range_fuzztests(::Type{T}, niter, nrange) where {T}
            for i = 1:niter, n in nrange
                strt, Δ = randn(T), randn(T)
                Δ == 0 && continue
                stop = strt + (n-1)*Δ
                # `n` is not necessarily unique s.t. `strt + (n-1)*Δ == stop`
                # so test that `length(strt:Δ:stop)` satisfies this identity
                # and is the closest value to `(stop-strt)/Δ` to do so
                lo = hi = n
                while strt + (lo-1)*Δ == stop; lo -= 1; end
                while strt + (hi-1)*Δ == stop; hi += 1; end
                m = clamp(round(Int, (stop-strt)/Δ) + 1, lo+1, hi-1)
                r = strt:Δ:stop
                @test m == length(r)
                @test strt == first(r)
                @test Δ == step(r)
                @test_skip stop == last(r)
                l = range(strt, stop=stop, length=n)
                @test n == length(l)
                @test strt == first(l)
                @test stop  == last(l)
            end
        end

        @testset "range fuzztests for $T" for T = (Float32, Float64,)
            range_fuzztests(T, 2^15, frange(1, 5))
        end

        @testset "range with very large endpoints for type $T" for T = (Float32, Float64)
            largeint = Int(min(maxintfloat(T), typemax(Int)))
            a = floatmax()
            for i = 1:5
                @test [frange(a, stop=a, length=1);] == [a]
                @test [frange(-a, stop=-a, length=1);] == [-a]
                b = floatmax()
                for j = 1:5
                    @test [frange(-a, stop=b, length=0);] == []
                    @test [frange(-a, stop=b, length=2);] == [-a,b]
                    @test [frange(-a, stop=b, length=3);] == [-a,(b-a)/2,b]
                    @test [frange(a, stop=-b, length=0);] == []
                    @test [frange(a, stop=-b, length=2);] == [a,-b]
                    @test [frange(a, stop=-b, length=3);] == [a,(a-b)/2,-b]
                    for c = largeint-3:largeint
                        s = range(-a, stop=b, length=c)
                        @test first(s) == -a
                        @test last(s) == b
                        @test length(s) == c
                        s = range(a, stop=-b, length=c)
                        @test first(s) == a
                        @test last(s) == -b
                        @test length(s) == c
                    end
                    b = prevfloat(b)
                end
                a = prevfloat(a)
            end
        end

        @testset "ranges with very small endpoints for type $T" for T = (Float32, Float64)
            z = zero(T)
            u = eps(z)
            @test first(frange(u, stop=u, length=0)) == u
            @test last(frange(u, stop=u, length=0)) == u
            @test first(frange(-u, stop=u, length=0)) == -u
            @test last(frange(-u, stop=u, length=0)) == u
            @test [frange(-u, stop=u, length=0);] == []
            @test [frange(-u, stop=-u, length=1);] == [-u]
            @test [frange(-u, stop=u, length=2);] == [-u,u]
            @test [frange(-u, stop=u, length=3);] == [-u,0,u]
            @test first(frange(-u, stop=-u, length=0)) == -u
            @test last(frange(-u, stop=-u, length=0)) == -u
            @test first(frange(u, stop=-u, length=0)) == u
            @test last(frange(u, stop=-u, length=0)) == -u
            @test [frange(u, stop=-u, length=0);] == []
            @test [frange(u, stop=u, length=1);] == [u]
            @test [frange(u, stop=-u, length=2);] == [u,-u]
            @test [frange(u, stop=-u, length=3);] == [u,0,-u]
            v = frange(-u, stop=u, length=12)
            @test length(v) == 12
            @test [-3u:u:3u;] == [frange(-3u, stop=3u, length=7);] == [-3:3;].*u
            @test [3u:-u:-3u;] == [frange(3u, stop=-3u, length=7);] == [3:-1:-3;].*u
        end

        @testset "tricky floating-point ranges" begin
            for (start, step, stop, len) in ((1, 1, 3, 3),
                                             (0, 1, 3, 4),
                                             (3, -1, -1, 5),
                                             (1, -1, -3, 5),
                                             (0, 1, 10, 11),
                                             (0, 7, 21, 4),
                                             (0, 11, 33, 4),
                                             (1, 11, 34, 4),
                                             (0, 13, 39, 4),
                                             (1, 13, 40, 4),
                                             (11, 11, 33, 3),
                                             (3, 1, 11, 9),
                                             (0, 10, 55, 0),
                                             (0, -1, 5, 0),
                                             (0, 10, 5, 0),
                                             (0, 1, 5, 0),
                                             (0, -10, 5, 0),
                                             (0, -10, 0, 1),
                                             (0, -1, 1, 0),
                                             (0, 1, -1, 0),
                                             (0, -1, -10, 11))
                r = frange(start/10, step=step/10, stop=stop/10)
                a = Vector(frange(start, step=step, stop=stop))./10
                ra = Vector(r)

                @test r == a
                @test isequal(r, a)

                @test r == ra
                @test isequal(r, ra)

                @test hash(r) == hash(a)
                @test hash(r) == hash(ra)

                if len > 0
                    l = frange(start/10, stop=stop/10, length=len)
                    la = Vector(l)

                    @test a == l
                    @test r == l
                    @test isequal(a, l)
                    @test isequal(r, l)

                    @test l == la
                    @test isequal(l, la)

                    @test hash(l) == hash(a)
                    @test hash(l) == hash(la)
                end
            end

            @test 1.0:1/49:27.0 == range(1.0, stop=27.0, length=1275) == [49:1323;]./49
            @test isequal(1.0:1/49:27.0, range(1.0, stop=27.0, length=1275))
            @test isequal(frange(1.0, step=1/49, stop=27.0), Vector(49:1323)./49)
            @test hash(1.0:1/49:27.0) == hash(frange(1.0, stop=27.0, length=1275)) == hash(Vector(frange(49, 1323))./49)

            @test [frange(prevfloat(0.1), step=0.1, stop=0.3);] == [prevfloat(0.1), 0.2, 0.3]
            @test [frange(nextfloat(0.1), step=0.1, stop=0.3);] == [nextfloat(0.1), 0.2]
            @test [frange(prevfloat(0.0), step=0.1, stop=0.3);] == [prevfloat(0.0), 0.1, 0.2]
            @test [frange(nextfloat(0.0), step=0.1, stop=0.3);] == [nextfloat(0.0), 0.1, 0.2]
            @test [frange(0.1, step=0.1, stop=prevfloat(0.3));] == [0.1, 0.2]
            @test [frange(0.1, step=0.1, stop=nextfloat(0.3));] == [0.1, 0.2, nextfloat(0.3)]
            @test [frange(0.0, step=0.1, stop=prevfloat(0.3));] == [0.0, 0.1, 0.2]
            @test [frange(0.0, step=0.1, stop=nextfloat(0.3));] == [0.0, 0.1, 0.2, nextfloat(0.3)]
            @test [frange(0.1, step=prevfloat(0.1), stop=0.3);] == [0.1, 0.2, 0.3]
            @test [frange(0.1, step=nextfloat(0.1), stop=0.3);] == [0.1, 0.2]
            @test [frange(0.0, step=prevfloat(0.1), stop=0.3);] == [0.0, prevfloat(0.1), prevfloat(0.2), 0.3]
            @test [frange(0.0, step=nextfloat(0.1), stop=0.3);] == [0.0, nextfloat(0.1), nextfloat(0.2)]
        end

        @testset "overflowing sums (see #5798)" begin
            if Sys.WORD_SIZE == 64
                @test sum(frange(Int128(1), 10^18)) == div(10^18 * (Int128(10^18)+1), 2)
                @test sum(frange(Int128(1), 10^18-1)) == div(10^18 * (Int128(10^18)-1), 2)
            else
                @test sum(frange(Int64(1), 10^9)) == div(10^9 * (Int64(10^9)+1), 2)
                @test sum(frange(Int64(1), 10^9-1)) == div(10^9 * (Int64(10^9)-1), 2)
            end
        end

        @testset "issue #20373 (unliftable ranges with exact end points)" begin
            @test [3*0.05:0.05:0.2;]    == [frange(3*0.05, stop=0.2, length=2);]   == [3*0.05,0.2]
            @test [0.2:-0.05:3*0.05;]   == [frange(0.2, stop=3*0.05, length=2);]   == [0.2,3*0.05]
            @test [-3*0.05:-0.05:-0.2;] == [frange(-3*0.05, stop=-0.2, length=2);] == [-3*0.05,-0.2]
            @test [-0.2:0.05:-3*0.05;]  == [frange(-0.2, stop=-3*0.05, length=2);] == [-0.2,-3*0.05]
        end

        @testset "issue #6973" begin
            r1 = frange(1.0, step=0.1, stop=2.0)
            r2 = frange(1.0f0, step=0.2f0, stop=3.0f0)
            r3 = frange(1, step=2, stop=21)
            @test r1 + r1 == 2*r1
            @test r1 + r2 == 2.0:0.3:5.0
            @test (r1 + r2) - r2 == r1
            @test r1 + r3 == convert(StepRangeLen{Float64}, r3) + r1
            @test r3 + r3 == 2 * r3
        end

       @testset "Inexact errors on 32 bit architectures. #22613" begin
            @test first(frange(log(0.2), stop=log(10.0), length=10)) == log(0.2)
            @test last(frange(log(0.2), stop=log(10.0), length=10)) == log(10.0)
            # not used internally for StaticRanges
            #@test length(Base.floatrange(-3e9, 1.0, 1, 1.0)) == 1
        end

        # issue #7426
        @test [frange(typemax(Int), step=1, stop=typemax(Int));] == [typemax(Int)]

        @testset "issue #7387" begin
            for r in (frange(0, 1), frange(0.0, 1.0))
                local r
                @test [r .+ im;] == [r;] .+ im
                @test [r .- im;] == [r;] .- im
                @test [r * im;] == [r;] * im
                @test [r / im;] == [r;] / im
            end
        end

        # near-equal ranges
        @test frange(0.0, step=0.1, stop=1.0) != 0.0f0:0.1f0:1.0f0

        #issue #7484
        let r7484 = frange(0.1, step=0.1, stop=1)
            @test [reverse(r7484);] == reverse([r7484;])
        end

        # issue #2959
        @test frange(1.0, 1.5) == 1.0:1.0:1.5 == 1.0:1.0

        @testset "comparing UnitRanges and OneTo" begin
            @test frange(1, step=2, stop=10) == 1:2:10 != 1:3:10 != 1:3:13 != frange(2, step=3, stop=13) == 2:3:11 != frange(2, 11)
            @test frange(1, step=1, stop=10) == 1:10 == 1:10 == OneToMRange(10) == static(OneTo(10))
            @test 1:10 != frange(2, 10) != 2:11 != Base.OneTo(11)
            @test OneToMRange(10) != static(OneTo(11)) != frange(1, 10)
        end

        @testset "issue #7114" begin
            let r = frange(-0.004532318104333742, step=1.2597349521122731e-5, stop=0.008065031416788989)
                @test length(r[1:end-1]) == length(r) - 1
                @test isa(r[1:2:end],AbstractRange) && length(r[1:2:end]) == div(length(r)+1, 2)
                @test r[3:5][2] ≈ r[4]
                @test r[5:-2:1][2] ≈ r[3]
                @test_throws BoundsError r[0:10]
                @test_throws BoundsError r[1:10000]
            end

            let r = frange(1/3, stop=5/7, length=6)
                @test length(r) == 6
                @test r[1] == 1/3
                @test abs(r[end] - 5/7) <= eps(5/7)
            end

            let r = frange(0.25, stop=0.25, length=1)
                @test length(r) == 1
                @test_throws ArgumentError frange(0.25, stop=0.5, length=1)
            end
        end


        # Preservation of high precision upon addition
        let r = range(-0.1, step=0.1, stop=0.3) + broadcast(+, -0.3:0.1:0.1, 1e-12)
            @test r[3] == 1e-12
        end

        @testset "range with 1 or 0 elements (whose step length is NaN)" begin
            @test issorted(frange(1, stop=1, length=0))
            @test issorted(frange(1, stop=1, length=1))
        end
        @testset "indexing range with empty range (#4309)" begin
            @test frange(3, 6)[5:4] == 7:6
            @test_throws BoundsError frange(3, 6)[5:5]
            @test_throws BoundsError frange(3, 6)[5]
            @test frange(0, step=2, stop=10)[7:6] == 12:2:10
            @test_throws BoundsError (0:2:10)[7:7]
        end
        # indexing with negative ranges (#8351)
        for a=AbstractRange[3:6, frange(0, step=2, stop=10)], b=AbstractRange[frange(0, 1), frange(2, step=-1, stop=0)]
            @test_throws BoundsError a[b]
        end
        @testset "sort/sort!/partialsort" begin
            @test sort(frange(1, 2)) == UnitRange(1,2)
            if frange == mrange
                @test sort!(frange(1, 2)) == UnitRange(1,2)
            end
            @test sort(frange(1, 10), rev=true) == 10:-1:1
            @test sort(frange(-3, 3), by=abs) == [0,-1,1,-2,2,-3,3]
            @test partialsort(frange(1, 10), 4) == 4
        end

        if frange == mrange
            # this works with `srange` but takes way too long to run.
            function loop_range_values(::Type{T}) where T
                for a = -5:25,
                    s = [-5:-1; 1:25; ],
                    d = 1:25,
                    n = -1:15

                    denom = convert(T, d)
                    strt = convert(T, a)/denom
                    Δ     = convert(T, s)/denom
                    stop  = convert(T, (a + (n - 1) * s)) / denom
                    vals  = T[a:s:(a + (n - 1) * s); ] ./ denom
                    r = strt:Δ:stop
                    @test [r;] == vals
                    @test [frange(strt, stop=stop, length=length(r));] == vals
                    n = length(r)
                    @test [r[1:n];] == [r;]
                    @test [r[2:n];] == [r;][2:end]
                    @test [r[1:3:n];] == [r;][1:3:n]
                    @test [r[2:2:n];] == [r;][2:2:n]
                    @test [r[n:-1:2];] == [r;][n:-1:2]
                    @test [r[n:-2:1];] == [r;][n:-2:1]
                end
            end

            @testset "issue #7420 for type $T" for T = (Float32, Float64,) # BigFloat),
                loop_range_values(T)
            end
        end

        # comparing and hashing ranges
        @testset "comparing and hashing ranges" begin
            Rs = AbstractRange[]
            for r in (frange(1, 1),
                      frange(1, step=1, stop=1),
                      frange(1, 2),
                      frange(1, step=1, stop=2),
                      map(Int32, frange(1, step=3, stop=17)),
                      map(Int64, frange(1, step=3, stop=17)),
                      frange(1, 0),
                      frange(1, step=-1, stop=0),
                      frange(17, 0, step=-3),
                      frange(0.0, step=0.1, stop=1.0),
                      map(Float32, frange(0.0, step=0.1, stop=1.0)),
                      frange(1.0, step=eps(), stop=1.0) .+ 10eps(),
                      frange(9007199254740990., step=1.0, stop=9007199254740994),
                      frange(0, stop=1, length=20),
                      map(Float32, frange(0, stop=1, length=20)))
                local r
                ar = Vector(r)
                @test r == ar
                @test isequal(r,ar)
                @test hash(r) == hash(ar)
                for s in Rs
                    as = Vector(s)
                    @test isequal(r,s) == (hash(r)==hash(s))
                    @test (r==s) == (ar==as)
                end
            end
        end
    end
end

#=  TODO mod with ranges
@testset "mod with ranges" begin
    for n in -10:10
        @test mod(n, 0:4) == mod(n, 5)
        @test mod(n, 1:5) == mod1(n, 5)
        @test mod(n, 2:6) == 2 + mod(n-2, 5)
        @test mod(n, Base.OneTo(5)) == mod1(n, 5)
    end
    @test mod(Int32(3), 1:5) == 3
    @test mod(big(typemax(Int))+99, 0:4) == mod(big(typemax(Int))+99, 5)
    @test_throws MethodError mod(3.141, 1:5)
    @test_throws MethodError mod(3, UnitRange(1.0,5.0))
    @test_throws MethodError mod(3, 1:2:7)
    @test_throws DivideError mod(3, 1:0)
end
=#
for frange in (mrange,srange)
    @testset "reverse-$frange" begin
        @test reverse(reverse(frange(1, 10))) == 1:10
        @test reverse(reverse(frange(typemin(Int), typemax(Int)))) == typemin(Int):typemax(Int)
        @test reverse(reverse(frange(typemin(Int), step=2, stop=typemax(Int)))) == typemin(Int):2:typemax(Int)
    end
end

r = MutableRange(1:1:10)
@test reverse!(r) == reverse(1:1:10)
@test reverse!(r) == 1:1:10

@testset "resize tests" begin
    include("resize_tests.jl")
end

include("count_tests.jl")

#=
#@test 1.0:(.3-.1)/.1 == 1.0:2.0
=#

#=
detect_ambiguities(StaticRanges,Base,Core)


=#
