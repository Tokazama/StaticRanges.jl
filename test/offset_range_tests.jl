
@testset "Offset Ranges" begin
    x = IdOffsetRange(UnitMRange(1, 10), 0)

    @test can_set_first(typeof(x))
    @test can_set_last(typeof(x))
    @test can_set_length(typeof(x))

    @test is_static(as_static(x))
    @test is_fixed(as_static(x))
    @test !can_change_size(as_static(x))

    @test !is_static(as_fixed(x))
    @test is_fixed(as_fixed(x))
    @test !can_change_size(as_fixed(x))

    @test !is_static(as_dynamic(x))
    @test !is_fixed(as_dynamic(x))
    @test can_change_size(as_dynamic(x))

    start = first(x)
    start_p1 = start + 1
    offset_x = set_first(x, start_p1)
    @test first(offset_x) == start_p1
    @test first(x) == start

    offset_x = set_first!(x, start_p1)
    @test first(offset_x) == start_p1 == first(x)

    stop = last(x)
    stop_p1 = stop + 1
    offset_x = set_last(x, stop_p1)
    @test last(offset_x) == stop_p1
    @test last(x) == stop

    offset_x = set_last!(x, stop_p1)
    @test last(offset_x) == stop_p1 == last(x)

    len = length(x)
    len_p1 = len + 1
    offset_x = set_length(x, len_p1)
    @test length(offset_x) == len_p1
    @test length(x) == len

    offset_x = set_length!(x, len_p1)
    @test length(offset_x) == len_p1 == length(x)

    @test StaticRanges.has_offset_axes(typeof(offset_x))
end

