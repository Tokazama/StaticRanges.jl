
"""
    UnitSRange

A static range parameterized by a `start` and `stop` of type `T`, filled with
elements spaced by `1` from `start` until `stop` is exceeded. The syntax `a:b`
with `a` and `b` both `Integer`s creates a `UnitRange`.
"""
struct UnitSRange{T,F,L} <: AbstractUnitRange{T}

    function UnitSRange{T,F,L}() where {T<:Real,F,L}
        F isa T || error("UnitSRange has eltype $T specified but starting value of type $(typeof(F))")
        L isa T || error("UnitSRange has eltype $T specified but starting value of type $(typeof(L))")
        return new{T,F,Base.unitrange_last(F, L)}()
    end

    function UnitSRange{T}(start, stop) where {T<:Real}
        return new{T,start,Base.unitrange_last(start,stop)}()
    end

    function UnitSRange{T,F,L}(r::AbstractRange) where {T<:Real,F,L}
        return UnitSRange{T}(r)
    end
    function UnitSRange{T,F,L}(start, stop) where {T<:Real,F,L}
        return UnitSRange{T,T(start),T(stop)}()
    end

    function UnitSRange{T}(r::AbstractUnitRange{T}) where {T}
        if r isa UnitSRange
            return r
        else
            return UnitSRange(first(r), last(r))
        end
    end

    UnitSRange{T}(r::AbstractUnitRange) where {T} = UnitSRange{T}(first(r), last(r))

    UnitSRange(start::T, stop::T) where {T<:Real} = UnitSRange{T}(start, stop)

    UnitSRange(r::AbstractUnitRange{T}) where {T} = UnitSRange{T}(r)
end


function Base.getproperty(r::UnitSRange, s::Symbol)
    if s === :start
        return first(r)
    elseif s === :stop
        return last(r)
    else
        error("type $(typeof(r)) has no property $s")
    end
end

Base.AbstractUnitRange{T}(r::UnitSRange) where {T} = UnitSRange{T}(r)

"""
    UnitMRange

A mutable range parameterized by a `start` and `stop` of type `T`, filled with
elements spaced by `1` from `start` until `stop` is exceeded. The syntax `a:b`
with `a` and `b` both `Integer`s creates a `UnitRange`.
"""
mutable struct UnitMRange{T<:Real} <: AbstractUnitRange{T}
    start::T
    stop::T

    function UnitMRange{T}(start, stop) where {T<:Real}
        return new(start, Base.unitrange_last(T(start), T(stop)))
    end

    UnitMRange{T}(r::AbstractUnitRange) where {T<:Real} = UnitMRange{T}(first(r), last(r))

    UnitMRange(start::T, stop::T) where {T<:Real} = UnitMRange{T}(start, stop)

    UnitMRange(r::AbstractUnitRange) = UnitMRange(first(r), last(r))
end


function Base.setproperty!(r::UnitMRange, s::Symbol, val)
    if s === :start
        return set_first!(r, val)
    elseif s === :stop
        return set_last!(r, val)
    else
        error("type $(typeof(r)) has no property $s")
    end
end

Base.AbstractUnitRange{T}(r::UnitMRange) where {T} = UnitMRange{T}(r)

