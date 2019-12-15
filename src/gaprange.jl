
"""
    GapRange{T,F,L}

Represents a range that is broken up by gaps making it noncontinuous.

## Examples
```jldoctest
julia> r = 1:10
1:10

julia> findall(or(<(4), >(12)), mr)
7-element Array{Int64,1}:
  1
  2
  3
  7
  8
  9
 10

julia> find_all(or(<(4), >(6)), r)
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
struct GapRange{T,F<:AbstractVector{T},L<:AbstractVector{T}} <: AbstractVector{T}
    first_range::F
    last_range::L
end

const GapRangeOrRange{T} = Union{GapRange{T},AbstractRange{T}}

function GapRange(f::GapRangeOrRange{T}, l::GapRangeOrRange{T}) where {T}
    if is_forward(f)
        if is_forward(f)
            if is_before(f, l)
                return GapRange{T,typeof(f),typeof(l)}(f, l)
            elseif is_before(l, f)
                return GapRange{T,typeof(l),typeof(f)}(l, f)
            else
                error("The two ranges composing a GapRange can't have any overlap.")
            end
        else
            error("Both arguments to GapRange must have the same sorting, got forward and reverse ordered ranges.")
        end
    else  # is_reverse(f)
        if is_forward(f)
            error("Both arguments to GapRange must have the same sorting, got reverse and forward ordered ranges.")
        else
            if is_after(f, l)
                return GapRange{T,typeof(f),typeof(l)}(f, l)
            elseif is_after(l, f)
                return GapRange{T,typeof(l),typeof(f)}(l, f)
            else
                error("The two ranges composing a GapRange can't have any overlap.")
            end
        end
    end
end

Base.iterate(gr::GapRange) = first(gr), 1

function Base.iterate(gr::GapRange, i::Integer)
    fl = first_length(gr)
    if i > fl
        if i >= last_length(gr)
            return nothing
        else
            inext = i + 1
            return unsafe_index_last(gr, inext), inext
        end
    elseif i == fl
        return first(last_range(gr)), i + 1
    else
        inext = i + 1
        return unsafe_index_first(gr, inext), inext
    end
end

