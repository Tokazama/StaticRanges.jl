
Length(::Type{OneToSRange{T,L}}) where {T,L} = Length{Int(L)}()

Length(::Type{LinSRange{T,B,E,L,D}}) where {T,B,E,L,D} = Length{L}()

function Length(::Type{UnitSRange{T,F,L}})  where {T<:Union{UInt,UInt64,UInt128},F,L}
    return Length{L < F ? 0 : Int(Base.Checked.checked_add(L - F, one(T)))}()
end

function Length(::Type{UnitSRange{T,F,L}}) where {T<:Union{Int,Int64,Int128},F,L}
    return Length{Int(Base.Checked.checked_add(Base.Checked.checked_sub(L, F), one(T)))}()
end

Base.length(r::OneToMRange) = Int(last(r))

Base.length(r::OneToSRange{T,L}) where {T,L} = Int(L)

Base.length(::StepSRangeLen{T,Tr,Ts,R,S,L,F}) where {T,Tr,Ts,R,S,L,F} = L

Base.length(r::StepMRangeLen) = getfield(r, :len)

Base.length(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = L

lendiv(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = D

Base.length(r::LinMRange) = getfield(r, :len)

function Base.length(r::AbstractStepRange{T}) where {T}
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
julia> using StaticRanges

julia> mr = UnitMRange(1, 10);

julia> set_length!(mr, 20);

julia> length(mr)
20
```
"""
function set_length!(x::AbstractRange{T}, len) where {T}
    if has_ref(x)
        len >= 0 || throw(ArgumentError("length cannot be negative, got $len"))
        1 <= x.offset <= max(1,len) || throw(ArgumentError("StepMRangeLen: offset must be in [1,$len], got $offset"))
        setfield!(x, :len, Int(len))
    else
        len >= 0 || throw(ArgumentError("set_length!($x, $len): negative length"))
        if len == 1
            x.start == x.stop || throw(ArgumentError("set_length!($x, $len): endpoints differ"))
            setfield!(x, :len, 1)
            setfield!(x, :lendiv, 1)
        else
            setfield!(x, :len, Int(len))
            setfield!(x, :lendiv, Int(max(len - 1, 1)))
        end
    end
    return x
end

function set_length!(x::OrdinalRange{T}, len) where {T}
    can_set_length(x) || throw(MethodError(set_length!, (x, len)))
    setfield!(x, :stop, convert(T, first(x) + step(x) * (len - 1)))
    return x
end

function set_length!(x::AbstractUnitRange{T}, len) where {T}
    can_set_length(x) || throw(MethodError(set_length!, (x, len)))
    if known_first(x) === one(T)
        set_last!(x, len)
    else
        set_last!(x, T(first(x)+len-1))
    end
    return x
end

"""
    set_length(x, len)

Change the length of `x` while maintaining it's first and last positions.

## Examples
```jldoctest
julia> using StaticRanges

julia> set_length(1:10, 20)
1:20
```
"""
function set_length(x::AbstractRange, len)
    if has_ref(x)
        return typeof(x)(x.ref, x.step, len, x.offset)
    else
        return typeof(x)(first(x), last(x), len)
    end
end


function set_length(x::AbstractUnitRange{T}, len) where {T}
    if known_first(x) === oneunit(T)
        return set_last(x, len)
    else
        return set_last(x, T(first(x)+len-1))
    end
end

function set_length(x::OrdinalRange{T}, len) where {T}
    return set_last(x, convert(T, first(x) + step(x) * (len - 1)))
end

"""
    set_lendiv!(r, d)

Change the length of `x` while maintaining it's first and last positions.
"""
set_lendiv!(r::LinMRange, d) = set_lendiv!(r, Int(d))
function set_lendiv!(r::LinMRange, d::Int)
    d >= 0 || throw(ArgumentError("set_length!($r, $d): negative length"))
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
