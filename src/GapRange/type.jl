"""
    GapRange{T,F,L}

Represents a range that is broken up by gaps making it noncontinuous. This allows
more compact storage of numbers where the majority are known to be continuous.

## Examples
```jldoctest
julia> using StaticRanges

julia> findall(and(>(4), <(10)), 1:10)
5-element Array{Int64,1}:
 5
 6
 7
 8
 9

julia> find_all(or(<(4), >(6)), 1:10)
7-element GapRange{Int64,UnitRange{Int64},UnitRange{Int64}}:
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
    if is_forward(l)
        if is_before(f, l)
            return GapRange{T,T,typeof(l)}(f, l)
        elseif is_after(f, l)
            return GapRange{T,typeof(l),T}(l, f)
        else
            error("The two ranges composing a GapRange can't overlap.")
        end
    else  # is_reverse(f)
        if is_after(f, l)
            return GapRange{T,T,typeof(l)}(f, l)
        elseif is_after(l, f)
            return GapRange{T,typeof(l),T}(l, f)
        else
            error("The two ranges composing a GapRange can't overlap.")
        end
    end
end

function GapRange(f::AbstractVector{T}, l::T) where {T<:Real}
    if is_forward(f)
        if is_before(f, l)
            return GapRange{T,typeof(f),T}(f, l)
        elseif is_before(l, f)
            return GapRange{T,T,typeof(f)}(l, f)
        else
            error("The two ranges composing a GapRange can't overlap.")
        end
    else  # is_reverse(f)
        if is_after(f, l)
            return GapRange{T,typeof(f),T}(f, l)
        elseif is_after(l, f)
            return GapRange{T,T,typeof(f)}(l, f)
        else
            error("The two ranges composing a GapRange can't overlap.")
        end
    end
end

function GapRange(f::AbstractVector{T}, l::AbstractVector{T}) where {T}
    if is_forward(f)
        if is_forward(l)
            if is_before(f, l)
                return GapRange{T,typeof(f),typeof(l)}(f, l)
            elseif is_before(l, f)
                return GapRange{T,typeof(l),typeof(f)}(l, f)
            else
                error("The two ranges composing a GapRange can't overlap.")
            end
        else
            error("Both arguments to GapRange must have the same sorting, got forward and reverse ordered ranges.")
        end
    else  # is_reverse(f)
        if is_forward(l)
            error("Both arguments to GapRange must have the same sorting, got reverse and forward ordered ranges.")
        else
            if is_after(f, l)
                return GapRange{T,typeof(f),typeof(l)}(f, l)
            elseif is_after(l, f)
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

is_reverse(x::GapRange) = is_reverse(first_range(x))
is_forward(x::GapRange) = is_forward(first_range(x))

is_forward(x::GapRange{T,T,L}) where {T,L} = is_forward(last_range(x))
is_forward(x::GapRange{T,F,T}) where {T,F} = is_forward(first_range(x))
is_forward(x::GapRange{T,T,T}) where {T} = first_range(x) < last_range(x)

is_reverse(x::GapRange{T,T,L}) where {T,L} = is_reverse(last_range(x))
is_reverse(x::GapRange{T,F,T}) where {T,F} = is_reverse(first_range(x))
is_reverse(x::GapRange{T,T,T}) where {T} = first_range(x) > last_range(x)

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

