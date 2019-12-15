
Base.length(r::OneToMRange) = Int(last(r))

Base.length(r::OneToSRange{T,L}) where {T,L} = Int(L)

Base.length(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = L

Base.length(r::StepMRangeLen) = getfield(r, :len)

Base.length(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = L

lendiv(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = D

Base.length(r::LinMRange) = getfield(r, :len)

Base.length(r::StepSRange) = StaticArrays.get(Length(r))

function Base.length(r::StepMRange{T}) where {T}
    return start_step_stop_to_length(T, first(r), step(r), last(r))
end

function Base.length(r::UnitMRange{T})  where {T<:Union{UInt,UInt64,UInt128}}
    return last(r) < first(r) ? 0 : Int(Base.Checked.checked_add(last(r) - first(r), one(T)))
end

function Base.length(r::UnitSRange{T,F,L})  where {T<:Union{UInt,UInt64,UInt128},F,L}
    return L < F ? 0 : Int(Base.Checked.checked_add(L - F, one(T)))
end

function Base.length(r::UnitSRange{T,F,L}) where {T<:Union{Int,Int64,Int128},F,L}
    return Int(Base.Checked.checked_add(Base.Checked.checked_sub(L, F), one(T)))
end

function Base.length(r::UnitMRange{T}) where {T<:Union{Int,Int64,Int128}}
    return Int(Base.Checked.checked_add(Base.Checked.checked_sub(last(r), first(r)), one(T)))
end

lendiv(r::LinMRange) = getfield(r, :lendiv)

# TODO document
first_length(gr::GapRange) = length(first_range(gr))

last_length(gr::GapRange) = length(last_range(gr))

Base.length(gr::GapRange) = length(first_range(gr)) + length(last_range(gr))

function start_step_stop_to_length(::Type{T}, start, step, stop) where {T}
    if (start != stop) & ((step > zero(step)) != (stop > start))
        return 0
    else
        return Int(div((stop - start) + step, step))
    end
end

function start_step_stop_to_length(::Type{T}, start, step, stop) where {T<:Union{Int,UInt,Int64,UInt64,Int128,UInt128}}
    if (start != stop) & ((step > zero(step)) != (stop > start))
        return 0
    elseif step > 1
        return Int(div(unsigned(stop - start), step)) + 1
    elseif step < -1
        return Int(div(unsigned(start - stop), -step)) + 1
    elseif step > 0
        return Int(div(stop - start, step) + 1)
    else
        return Int(div(start - stop, -step) + 1)
    end
end

# some special cases to favor default Int type
smallint = (Int === Int64 ? Union{Int8,UInt8,Int16,UInt16,Int32,UInt32} : Union{Int8,UInt8,Int16,UInt16})

function Base.length(r::AbstractStepRange{T}) where {T<:smallint}
    if isempty(r)
        return Int(0)
    else
        return div(Int(last(r))+Int(step(r)) - Int(first(r)), Int(step(r)))
    end
end
Base.length(r::OneToRange{<:smallint}) = Int(r.stop)

"""
    can_set_length(x) -> Bool

Returns `true` if type of `x` can have its length set independent of changing
its first or last position.
"""
can_set_length(::T) where {T} = can_set_length(T)
can_set_length(::Type{T}) where {T} = false
can_set_length(::Type{T}) where {T<:LinMRange} = true
can_set_length(::Type{T}) where {T<:StepMRangeLen} = true
can_set_length(::Type{T}) where {T<:StepMRange} = true
can_set_length(::Type{T}) where {T<:UnitMRange} = true
can_set_length(::Type{T}) where {T<:OneToMRange} = true

"""
    set_length!(x, len)

Returns a similar type as `x` with a length equal to `len`.

## Examples
```jldoctest
julia> mr = UnitMRange(1, 10)
UnitMRange(1:10)

julia> set_length!(mr, 20)
UnitMRange(1:20)

julia> length(mr)
20
```
"""
set_length!(r::AbstractRange, val) = set_length!(r, Int(val))
function set_length!(r::LinMRange, len::Int)
    len >= 0 || throw(ArgumentError("set_length!($r, $len): negative length"))
    if len == 1
        r.start == r.stop || throw(ArgumentError("set_length!($r, $len): endpoints differ"))
        setfield!(r, :len, 1)
        setfield!(r, :lendiv, 1)
        return r
    end
    setfield!(r, :len, len)
    setfield!(r, :lendiv, max(len - 1, 1))
    return r
end
function set_length!(r::StepMRangeLen, len::Int)
    len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
    1 <= r.offset <= max(1,len) || throw(ArgumentError("StepMRangeLen: offset must be in [1,$len], got $offset"))
    setfield!(r, :len, len)
    return r
end
set_length!(x::OneToMRange{T}, len::T) where {T} = set_last!(x, len)
set_length!(x::UnitMRange{T}, len) where {T} = set_last!(x, T(first(x)+len-1))
function set_length!(r::StepMRange{T}, len) where {T}
    setfield!(r, :stop, convert(T, first(r) + step(r) * (len - 1)))
    return r
end

"""
    set_length(x, len)

Change the length of `x` while maintaining it's first and last positions.

## Examples
```jldoctest
julia> r = 1:10
1:10

julia> set_length(r, 20)
1:20
```
"""
set_length(r::AbstractRange, val) = set_length(r, Int(val))
set_length(r::LinRangeUnion, len::Int) = similar_type(r)(first(r), last(r), len)
set_length(r::StepRangeLenUnion, len::Int) = similar_type(r)(r.ref, r.step, len, r.offset)
set_length(r::OneToUnion{T}, len::T) where {T} = similar_type(r)(len)
set_length(r::UnitRangeUnion{T}, len) where {T} = set_last(r, T(first(r) + len - 1))
function set_length(r::StepRangeUnion{T}, len) where {T}
    return set_last(r, convert(T, first(r) + step(r) * (len - 1)))
end

"""
    set_lendiv!(r, d)

Change the length of `x` while maintaining it's first and last positions.
"""
set_lendiv!(r::LinMRange, d) = set_lendiv!(r, Int(d))
function set_lendiv!(r::LinMRange, d::Int)
    d >= 0 || throw(ArgumentError("set_length!($r, $len): negative length"))
    #=
    we don't do this because on the off chance the user is intentionally
    setting lendiv we can't know if they want the length also set to 1 or 2
    if d == 1
        r.start == r.stop || throw(ArgumentError("set_length!($r, $len): endpoints differ"))
        setfield!(r, :len, 1)
        setfield!(r, :lendiv, 1)
        return r
    end
    =#
    setfield!(r, :len, d + 1)
    setfield!(r, :lendiv, d)
    return r
end
