
"""
    AbstractLinRange

Supertype for mutable or static ranges with `len` linearly spaced elements
between its `start` and `stop`.
"""
abstract type AbstractLinRange{T} <: AbstractRange{T} end

Base.firstindex(::AbstractLinRange) = 1

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
        return new{T, T(start), T(stop), len, max(len-1,1)}()
    end
end

LinSRange(start, stop, len::Integer) = LinSRange{typeof((stop-start)/len)}(start, stop, len)

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

LinMRange(start, stop, len::Integer) = LinMRange{typeof((stop-start)/len)}(start, stop, len)

LinMRange{T}(r::AbstractRange) where {T}= LinMRange{T}(first(r), last(r), length(r))

function Base.setproperty!(r::LinMRange, s::Symbol, val)
    if s === :start
        return set_first!(r, val)
    elseif s === :stop
        return set_last!(r, val)
    elseif s === :len
        return set_length!(r, val)
    elseif s === :lendiv
        return set_lendiv!(r, val)
    else
        error("type $(typeof(r)) has no property $s")
    end
end

for (F,f) in ((:M,:m), (:S,:s))
    LR = Symbol(:Lin, F, :Range)
    frange = Symbol(f, :range)

    @eval begin
        Base.:(-)(r::$(LR)) = $(LR)(-first(r), -last(r), length(r))

        $(LR){T}(r::$(LR){T}) where {T} = r
        #$(LR){T}(r::AbstractRange) where {T} = $(LR){T}(first(r), last(r), length(r))
        $(LR)(r::AbstractRange{T}) where {T} = $(LR){T}(r)

        function Base.:(-)(r1::$(LR){T}, r2::$(LR){T}) where T
            len = length(r1)
            (len == length(r2) ||
             throw(DimensionMismatch("argument dimensions must match")))
            return $(LR){T}(
                convert(T, -(first(r1), first(r2))),
                convert(T, -(last(r1), last(r2))),
                len
               )
        end

        function Base.:(+)(r1::$(LR){T}, r2::$(LR){T}) where T
            len = length(r1)
            (len == length(r2) ||
             throw(DimensionMismatch("argument dimensions must match")))
            return $(LR){T}(
                convert(T, +(first(r1), first(r2))),
                convert(T, +(last(r1), last(r2))),
                len
            )
        end
    end
end

