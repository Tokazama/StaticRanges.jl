using StaticRanges, Test

#=
# indexing with negative ranges (#8351)
for a=AbstractRange[srange(3:6), srange(0:2:10)], b=AbstractRange[srange(0:1), srange(2:-1:0)]
    @test_throws BoundsError a[b]
end
=#
