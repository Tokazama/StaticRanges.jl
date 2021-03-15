
"""
    GapRange{T,F,L}

Represents a range that is broken up by gaps making it noncontinuous. This allows
more compact storage of numbers where the majority are known to be continuous.

## Examples
```jldoctest
julia> using StaticRanges

julia> findall(and(>(4), <(10)), 1:10)
5-element Vector{Int64}:
 5
 6
 7
 8
 9

julia> find_all(or(<(4), >(6)), 1:10)
7-element GapRange{Int64, UnitRange{Int64}, UnitRange{Int64}}:
  1
  2
  3
  7
  8
  9
 10
```
"""
struct GapRange{T,F,L} <: AbstractVector{T}
    first_range::F
    last_range::L

   function GapRange{T,F,L}(fr::F, lr::L) where {T,F,L}
       if (eltype(fr) <: T) & (eltype(lr) <: T)
           if F <: AbstractRange || F <: GapRange || F <: T
               if L <: AbstractRange || L <: GapRange || L <: T
                   return new{T,F,L}(fr, lr)
               else
                   error("A GapRange can only be composed of ranges or othe GapRanges, got $L.")
               end
           else
               error("A GapRange can only be composed of ranges or othe GapRanges, got $F.")
           end
       else
           error("element type of first and last range must be the same, got $(eltype(fr)) and $(eltype(lr)).")
       end
    end
end

GapRange(f::T, l::T) where {T} = GapRange{T,T,T}(f, l)
function GapRange(f::T, l::AbstractVector{T}) where {T<:Real}
    if step(l) > 0
        if f < first(l)
            return GapRange{T,T,typeof(l)}(f, l)
        elseif f > last(l)
            return GapRange{T,typeof(l),T}(l, f)
        else
            error("The two ranges composing a GapRange can't overlap.")
        end
    else
        if f > first(l)
            return GapRange{T,T,typeof(l)}(f, l)
        elseif f < last(l)
            return GapRange{T,typeof(l),T}(l, f)
        else
            error("The two ranges composing a GapRange can't overlap.")
        end
    end
end

function GapRange(f::AbstractVector{T}, l::T) where {T<:Real}
    if step(f) > 0
        if last(f) < l
            return GapRange{T,typeof(f),T}(f, l)
        elseif l < first(f)
            return GapRange{T,T,typeof(f)}(l, f)
        else
            error("The two ranges composing a GapRange can't overlap.")
        end
    else
        if l > first(f)
            return GapRange{T,typeof(f),T}(f, l)
        elseif l < last(f)
            return GapRange{T,T,typeof(f)}(l, f)
        else
            error("The two ranges composing a GapRange can't overlap.")
        end
    end
end

function GapRange(f::AbstractVector{T}, l::AbstractVector{T}) where {T}
    if step(f) > 0
        if step(l) > 0
            if last(f) < first(l)
                return GapRange{T,typeof(f),typeof(l)}(f, l)
            elseif last(l) < first(f)
                return GapRange{T,typeof(l),typeof(f)}(l, f)
            else
                error("The two ranges composing a GapRange can't overlap.")
            end
        else
            error("Both arguments to GapRange must have the same sorting, got forward and reverse ordered ranges.")
        end
    else
        if step(l) > 0
            error("Both arguments to GapRange must have the same sorting, got reverse and forward ordered ranges.")
        else
            if last(f) > first(l)
                return GapRange{T,typeof(f),typeof(l)}(f, l)
            elseif last(l) > first(f)
                return GapRange{T,typeof(l),typeof(f)}(l, f)
            else
                error("The two ranges composing a GapRange can't overlap.")
            end
        end
    end
end

first_range(gr::GapRange) = getfield(gr, :first_range)
last_range(gr::GapRange) = getfield(gr, :last_range)

first_length(gr::GapRange) = length(first_range(gr))
first_length(gr::GapRange{T,T}) where {T} = 1

last_length(gr::GapRange) = length(last_range(gr))
last_length(gr::GapRange{T,F,T}) where {T,F} = 1

Base.length(gr::GapRange) = length(first_range(gr)) + length(last_range(gr))

Base.first(gr::GapRange) = first(first_range(gr))

Base.last(gr::GapRange) = last(last_range(gr))
Base.length(gr::GapRange{T,T,T}) where {T} = 2

# bypasses order checking
_unsafe_gaprange(f, l) = GapRange{eltype(f),typeof(f),typeof(l)}(f, l)


#Base.:(==)(x::GapRange, y::GapRange) = _isequal(x, y)
Base.:(==)(x::AbstractArray, y::GapRange) = _isequal(x, y)
Base.:(==)(x::GapRange, y::AbstractArray) = _isequal(x, y)
Base.:(==)(x::GapRange, y::GapRange) = _isequal(x, y)

function _isequal(x, y)
    out = true
    for (x_i,y_i) in zip(x,y)
        if x_i != y_i
            out = false
            break
        end
    end
    return out
end

Base.size(gr::GapRange) = (length(gr),)

Base.firstindex(gr::GapRange) = firstindex(first_range(gr))

first_lastindex(gr) = lastindex(first_range(gr))

Base.lastindex(gr::GapRange) = length(gr)

last_firstindex(gr::GapRange) = lastindex(first_range(gr)) + 1

function Base.AbstractArray{T}(gr::GapRange) where {T}
    fr = AbstractRange{T}(gr.first_range)
    lr = AbstractRange{T}(gr.last_range)
    return GapRange{T,typeof(fr),typeof(lr)}(fr, lr)
end
# GapRange
unsafe_index_first(gr::GapRange, i) = @inbounds(getindex(first_range(gr), i))
function unsafe_index_last(gr::GapRange, i)
    return @inbounds(getindex(last_range(gr), i .- first_length(gr)))
end

function Base.getindex(gr::GapRange, i::Integer)
    @boundscheck checkbounds(gr, i)
    return i <= first_length(gr) ? unsafe_index_first(gr, i) : unsafe_index_last(gr, i)
end

@propagate_inbounds function Base.getindex(r::AbstractRange, gr::GapRange)
    fr = r[gr.first_range]
    lr = r[gr.last_range]
    return GapRange{eltype(r),typeof(fr),typeof(lr)}(fr, lr)
end

@propagate_inbounds function Base.getindex(gr::GapRange, v::AbstractRange)
    @boundscheck checkbounds(gr, v)
    fr = first_range(gr)
    lr = last_range(gr)
    if checkindexhi(fr, minimum(v))
        if checkindexlo(lr, maximum(v))
            return unsafe_spanning_getindex(gr, v)
        else
            # largest value of `v` is not found in last segment so only index first segment
            return unsafe_index_first(gr, v)
        end
    else
        # smallest value of `v` is not found in first segment so only index last segment
        return unsafe_index_last(gr, v)
    end
end

function unsafe_spanning_getindex(gr, v)
    ltfli = find_all(<=(first_lastindex(gr)), v)
    gtlfi = find_all(>=(last_firstindex(gr)), v)
    if step(v) > 0
        return _unsafe_gaprange(
            unsafe_index_first(gr, @inbounds(v[ltfli])),
            unsafe_index_last(gr, @inbounds(v[gtlfi]))
           )
    else
        return _unsafe_gaprange(
            unsafe_index_last(gr, @inbounds(v[gtlfi])),
            unsafe_index_first(gr, @inbounds(v[ltfli]))
        )
    end
end

Base.checkbounds(::Type{Bool}, gr::GapRange, i::Integer) = checkindex(Bool, gr, i)

function Base.checkindex(::Type{Bool}, gr::GapRange, i::Integer)
    return checkindexlo(gr, i) & checkindexhi(gr, i)
end

