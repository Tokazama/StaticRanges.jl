
Length(::Type{OneToSRange{T,L}}) where {T,L} = Length{Int(L)}()

Length(::Type{LinSRange{T,B,E,L,D}}) where {T,B,E,L,D} = Length{L}()

function Length(::Type{UnitSRange{T,F,L}})  where {T<:Union{UInt,UInt64,UInt128},F,L}
    return Length{L < F ? 0 : Int(Base.Checked.checked_add(L - F, one(T)))}()
end

function Length(::Type{UnitSRange{T,F,L}}) where {T<:Union{Int,Int64,Int128},F,L}
    return Length{Int(Base.Checked.checked_add(Base.Checked.checked_sub(L, F), one(T)))}()
end

lendiv(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = D

lendiv(r::LinMRange) = getfield(r, :lendiv)

# some special cases to favor default Int type


"""
    can_set_length(x) -> Bool

Returns `true` if type of `x` can have its length set independent of changing
its first or last position.
"""
can_set_length(::T) where {T} = can_set_length(T)
can_set_length(::Type{T}) where {T} = false
can_set_length(::Type{T}) where {T<:AbstractRange} = is_dynamic(T)

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
