
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

unsafe_find_value(x, r::AbstractRange) = _int(_add1(div(x - static_first(r), static_step(r))))
_add1(x::T) where {T} = x + oneunit(T)
_int(idx) = round(Integer, idx, RoundToZero)
_int(idx::Integer) = idx
_int(idx::TwicePrecision{T}) where {T} = round(Integer, T(idx), RoundToZero)

# assume non empty
_is_forward(x::AbstractRange) = step(x) > zero(eltype(x))
_is_forward(x::AbstractUnitRange) = true

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
    if known_step(X) === nothing || known_step(Y) === nothing
        return 1:1:0
    else
        if first_is_known_one(x) && first_is_known_one(y)
            if known_last(x) isa Nothing || known_last(y) isa Nothing
                return static(1):0
            else
                return static(1):static(0)
            end
        else
            return 1:0
        end
    end
end

for (sym, f) in ((:lt, <), (:lteq, <=), (:gt, >), (:gteq, >=))
    for ord in (:first, :last)
        for kv in (:value_, Symbol(""))
            find_name = Symbol(:find_, ord, kv, sym)
            unsafe_find_name = Symbol(:unsafe_find_, ord, kv, sym)
            unsafe_find_name_forward = Symbol(:unsafe_find_, ord, kv, sym, :_forward)
            unsafe_find_name_reverse = Symbol(:unsafe_find_, ord, kv, sym, :_reverse)
            @eval begin
                function $find_name(x, collection)
                    if isempty(collection)
                        return nothing
                    else
                        return $unsafe_find_name(x, collection)
                    end
                end

                function $unsafe_find_name(x, collection::AbstractRange)
                    if _is_forward(collection)
                        return $unsafe_find_name_forward(x, collection)
                    else
                        return $unsafe_find_name_reverse(x, collection)
                    end
                end
            end

            if kv === :value
                if ord === :first
                    @eval begin
                        function $unsafe_find_name(x, collection)
                            for collection_i in collection
                                $f(x, collection_i) && return collection_i
                            end
                            return nothing
                        end
                    end
                else
                    @eval begin
                        function $unsafe_find_name(x, collection)
                            for collection_i in Iterators.reverse(collection)
                                $f(x, collection_i) && return collection_i
                            end
                            return nothing
                        end
                    end
                end
            else
                if ord === :first
                    @eval begin
                        function $unsafe_find_name(x, collection)
                            for (index, collection_i) in pairs(collection)
                                $f(collection_i, x) && return index
                            end
                            return nothing
                        end
                    end
                else
                    @eval begin
                        function $unsafe_find_name(x, collection)
                            for (index, collection_i) in Iterators.reverse(pairs(collection))
                                $f(collection_i, x) && return index
                            end
                            return nothing
                        end
                    end
               end
            end
        end
    end
end

include("find_all_in.jl")
include("find_first.jl")
include("find_last.jl")
include("find_all.jl")

