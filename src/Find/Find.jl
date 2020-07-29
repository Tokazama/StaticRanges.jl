
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
    find_all_in,
    find_all,
    find_alleq,
    find_allgt,
    find_alllt,
    find_allgteq,
    find_alllteq,
    find_max,
    find_min

# Ideally the previous _find_all_in method could be used, but things like `div(::Second, ::Integer)`
# don't work. So this helps drop units by didingin by oneunit(::T) of the same type.
drop_unit(x) = x / oneunit(x)
drop_unit(x::Real) = x



"""
    find_max(x)

Returns the index of the maximum value for `x`. Differes from `findmax` by
accounting for any sorting.
"""
find_max(x::AbstractVector) = findmax(x)
function find_max(x::AbstractRange)
    if isempty(x)
        throw(ArgumentError("collection must be non-empty"))
    else
        return unsafe_find_max(x)
    end
end
unsafe_find_max(x::AbstractUnitRange) = (last(x), lastindex(x))
function unsafe_find_max(x::AbstractRange)
    if step(x) > 0
        return (last(x), lastindex(x))
    else
        return (first(x), firstindex(x))
    end
end

"""
    find_min(x)

Returns the index of the minimum value for `x`. Differes from `findmin` by
accounting for any sorting.
"""
find_min(x::AbstractVector) = findmin(x)
function find_min(x::AbstractRange)
    if isempty(x)
        throw(ArgumentError("collection must be non-empty"))
    else
        return unsafe_find_min(x)
    end
end
unsafe_find_min(x::AbstractUnitRange) = (first(x), firstindex(x))
function unsafe_find_min(x::AbstractRange)
    if step(x) > 0
        return (first(x), firstindex(x))
    else
        return (last(x), lastindex(x))
    end
end

# only really applies to ordered vectors
_find_all(::Type{T},        fi,        li) where {T} = fi:li
_find_all(::Type{T}, ::Nothing,        li) where {T} = _empty_ur(T)
_find_all(::Type{T},        fi, ::Nothing) where {T} = _empty_ur(T)
_find_all(::Type{T}, ::Nothing, ::Nothing) where {T} = _empty_ur(T)
_empty_ur(::Type{T}) where {T} = one(T):zero(T)

_empty(x::X, y::Y) where {X,Y} = Vector{Int}()
@inline function _empty(x::X, y::Y) where {X<:AbstractRange,Y<:AbstractRange}
    R = similar_type(promote_type(typeof(x), typeof(y)), Int)
    T = eltype(R)
    if RangeInterface.has_step_field(R)
        return one(T):one(T):zero(T)
    else
        if RangeInterface.has_start_field(R)
            if RangeInterface.has_len_field(R)
                return one(T):one(T):zero(T)
            else
                R(x, y)
            end
        else
            return R(0)
        end
    end
end


include("find_all_in.jl")
include("findvalue.jl")
include("find_first.jl")
include("find_last.jl")
include("find_all.jl")

