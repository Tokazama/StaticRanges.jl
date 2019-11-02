"""
    AbstractLinRange

Supertype for mutable or static ranges with `len` linearly spaced elements
between its `start` and `stop`.
"""
abstract type AbstractLinRange{T} <: AbstractRange{T} end

Base.firstindex(::AbstractLinRange) = 1

Base.step(r::AbstractLinRange) = (last(r)-first(r)) / lendiv(r)

"""
    LinSRange

A static range with len linearly spaced elements between its start and stop.
The size of the spacing is controlled by len, which must be an Int.
"""
struct LinSRange{T,B,E,L,D} <: AbstractLinRange{T}
    function LinSRange{T}(start, stop, len) where T
        len >= 0 || throw(ArgumentError("srange($start, stop=$stop, length=$len): negative length"))
        if len == 1
            start == stop || throw(ArgumentError("srange($start, stop=$stop, length=$len): endpoints differ"))
            return new{T,start, stop, 1, 1}()
        end
        return new{T, start, stop, len, max(len-1,1)}()
    end
end

function LinSRange(start, stop, len::Integer)
    return LinSRange{typeof((stop-start)/len)}(start, stop, len)
end

function Base.getproperty(r::LinSRange, s::Symbol)
    if s === :start
        return first(r)
    elseif s === :stop
        return last(r)
    elseif s === :len
        return length(r)
    elseif s === :lendiv
        return lendiv(r)
    else
        error("type $(typeof(r)) has no property $s")
    end
end

Base.first(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = B

Base.last(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = E

Base.length(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = L

lendiv(::LinSRange{T,B,E,L,D}) where {T,B,E,L,D} = D

LinSRange{T}(r::AbstractRange) where {T} = LinSRange{T}(first(r), last(r), length(r))

"""
    LinMRange

A mutable range with len linearly spaced elements between its start and stop.
The size of the spacing is controlled by len, which must be an Int.
"""
mutable struct LinMRange{T} <: AbstractLinRange{T}
    start::T
    stop::T
    len::Int
    lendiv::Int

    function LinMRange{T}(start, stop, len) where T
        len >= 0 || throw(ArgumentError("mrange($start, stop=$stop, length=$len): negative length"))
        if len == 1
            start == stop || throw(ArgumentError("mrange($start, stop=$stop, length=$len): endpoints differ"))
            return new(start, stop, 1, 1)
        end
        return new(start, stop, len, max(len-1,1))
    end
end

function LinMRange(start, stop, len::Integer)
    return LinMRange{typeof((stop-start)/len)}(start, stop, len)
end

Base.first(r::LinMRange) = getfield(r, :start)

Base.last(r::LinMRange) = getfield(r, :stop)

Base.length(r::LinMRange) = getfield(r, :len)

lendiv(r::LinMRange) = getfield(r, :lendiv)

LinMRange{T}(r::AbstractRange) where {T}= LinMRange{T}(first(r), last(r), length(r))

for (F,f) in ((:M,:m), (:S,:s))
    LR = Symbol(:Lin, F, :Range)
    frange = Symbol(f, :range)

    @eval begin
        Base.:(-)(r::$(LR)) = $(LR)(-firs(r), -last(r), length(r))

        $(LR){T}(r::$(LR){T}) where {T} = r
        #$(LR){T}(r::AbstractRange) where {T} = $(LR){T}(first(r), last(r), length(r))
        $(LR)(r::AbstractRange{T}) where {T} = $(LR){T}(r)

        Base.reverse(r::$(LR)) = $(LR)(last(r), first(r), length(r))

        function Base.:(-)(r1::$(LR){T}, r2::$(LR){T}) where T
            len = _len(r1)
            (len == _len(r2) ||
             throw(DimensionMismatch("argument dimensions must match")))
            return $(LR){T}(
                convert(T, -(first(r1), first(r2))),
                convert(T, -(last(r1), last(r2))),
                len
               )
        end

        function Base.:(+)(r1::$(LR){T}, r2::$(LR){T}) where T
            len = _len(r1)
            (len == _len(r2) ||
             throw(DimensionMismatch("argument dimensions must match")))
            return $(LR){T}(
                convert(T, +(first(r1), first(r2))),
                convert(T, +(last(r1), last(r2))),
                len
               )
        end
    end
end
