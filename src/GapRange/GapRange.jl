
include("type.jl")
include("getindex.jl")
include("iterate.jl")

is_reverse(x::GapRange) = is_reverse(first_range(x))
is_forward(x::GapRange) = is_forward(first_range(x))

