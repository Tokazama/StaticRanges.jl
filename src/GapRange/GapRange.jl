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
        if fr isa T
            return _unsafe_gaprange(fr:fr, lr)
        elseif lr isa T
            return _unsafe_gaprange(fr, lr:lr)
        else
            check_gaprange_keytype(fr, lr)
            check_gaprange_type(fr, lr)
            return new{T,F,L}(fr, lr)
        end
    end
end

first_range(gr::GapRange) = getfield(gr, :first_range)
last_range(gr::GapRange) = getfield(gr, :last_range)

# TODO document
first_length(gr::GapRange) = length(first_range(gr))

last_length(gr::GapRange) = length(last_range(gr))

Base.length(gr::GapRange) = length(first_range(gr)) + length(last_range(gr))

Base.first(gr::GapRange) = first(first_range(gr))

Base.last(gr::GapRange) = last(last_range(gr))

# compile time checks for GapRange parameters
function check_gaprange_type(fr, lr) where {T}
    if !isa(fr, AbstractRange) & !isa(fr, GapRange)
        error("All segments of a GapRange must be another GapRange or AbstractRange,
              got $(typeof(fr)) for the first segment.")
    end
    if !isa(lr, AbstractRange) & !isa(lr, GapRange)
        error("All segments of a GapRange must be another GapRange or AbstractRange,
              got $(typeof(fr)) for the last segment.")
    end
    return nothing
end
function check_gaprange_keytype(fr, lr)
    if keytype(fr) != keytype(lr)
        error("The first segment and last segment of a GapRange must have the same keytypes,
              got $(keytype(fr)) and $(keytype(lr)).")
    end
    return nothing
end

# bypasses order checking
function _unsafe_gaprange(f, l)
    return GapRange{eltype(f),typeof(f),typeof(l)}(f, l)
end


function GapRange(f::AbstractVector{T}, l::AbstractVector{T}) where {T}
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



include("getindex.jl")
include("iterate.jl")

is_reverse(x::GapRange) = is_reverse(first_range(x))
is_forward(x::GapRange) = is_forward(first_range(x))

