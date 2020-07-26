
using ChainedFixes
using ArrayInterface: known_first, known_last, known_step

export
    and,
    ⩓,
    or,
    ⩔,
    # find
    find_first,
    find_firsteq,
    find_firstgt,
    find_firstlt,
    find_firstgteq,
    find_firstlteq,
    find_last,
    find_lasteq,
    find_lastgt,
    find_lastlt,
    find_lastgteq,
    find_lastlteq,
    find_in,
    find_all,
    find_alleq,
    find_allgt,
    find_alllt,
    find_allgteq,
    find_alllteq,
    find_max,
    find_min

# Ideally the previous _find_in method could be used, but things like `div(::Second, ::Integer)`
# don't work. So this helps drop units by didingin by oneunit(::T) of the same type.
drop_unit(x) = x / oneunit(x)
drop_unit(x::Real) = x

"""
    find_max(x)

Returns the index of the maximum value for `x`. Differes from `findmax` by
accounting for any sorting.
"""
find_max(x) = find_max(x, order(x))
find_max(x, ::ForwardOrdering) = (last(x), lastindex(x))
find_max(x, ::ReverseOrdering) = (first(x), firstindex(x))
find_max(x, ::UnorderedOrdering) = findmax(x)

"""
    find_min(x)

Returns the index of the minimum value for `x`. Differes from `findmin` by
accounting for any sorting.
"""
find_min(x) = find_min(x, order(x))
find_min(x, ::ForwardOrdering) = (first(x), firstindex(x))
find_min(x, ::ReverseOrdering) = (last(x), lastindex(x))
find_min(x, ::UnorderedOrdering) = findmin(x)

include("find_in.jl")
include("findvalue.jl")
include("find_first.jl")
include("find_last.jl")
include("find_all.jl")
