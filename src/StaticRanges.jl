module StaticRanges

using StaticArrays

import StaticArrays: tuple_length, tuple_prod, tuple_minimum

import Base: unsafe_getindex, getindex, checkbounds, @pure, ==, +, -, tail, eltype

import Base.Checked: checked_sub, checked_add

export StaticRange, OneToSRange, srange

"""
    StaticRange

"""
struct StaticRange{T,B,E,S,F,L} <: AbstractRange{T}
    StaticRange{T,B,E,S,F,L}() where {T,B,E,S,F,L} = new{T,B,E,S,F,L}()
end

const OneToSRange{N} = StaticRange{Int,1,N,1,1,N}
OneToSRange(N::Int) = OneToSRange{N}()

srange(start::Real; length::Union{Int,Nothing}=nothing, stop::Union{Real,Nothing}=nothing, step::Union{Real,Nothing}=nothing, offset::Int=1) =
    _srange(Val(start), Val(stop), Val(step), Val(offset), Val(length))

srange(start::Real, stop::Real; length::Union{Int,Nothing}=nothing, step::Union{Real,Nothing}=nothing, offset::Int=1) =
    _srange(Val(start), stop=Val(stop), step=Val(step), offset=Val(offset), length=Val(length))

srange(start::Val{B}; stop::Val{E}=Val(nothing), length::Val{L}=Val(nothing), step::Val{S}=Val(nothing), offset::Val{F}=Val(1)) where {B,E,S,F,L} =
    _srange(start, stop, step, offset, length)

srange(start::Val{B}, stop::Val{E}; length::Val{L}=Val(nothing), step::Val{S}=Val(nothing), offset::Val{F}=Val(1)) where {B,E,S,F,L} =
    _srange(start, stop, step, offset, length)

function _srange(
    b::Val{B},
    e::Val{nothing},
    s::Val{nothing},
    f::Val{F},
    len::Val{L}
   ) where {B,F,L}
    StaticRange{typeof(B),B,oftype(B, B+L-1),F,L}()
end

# 2. start, stop, length
function _srange(
    b::Val{B},
    e::Val{E},
    s::Val{nothing},
    f::Val{F},
    len::Val{L}
   ) where {B,E,F,L}
    _srange(b, e, Val(oftype(B, (E-B)/L)), f, len)
end

function _srange(
    b::Val{B},
    e::Val{E},
    s::Val{nothing},
    f::Val{F},
    len::Val{nothing}
   ) where {B,E,F}
    _srange(b, e, Val(oftype(B, 1)), f, Val(Int(E - B + 1)))
end

function _srange(
    b::Val{B},
    e::Val{E},
    s::Val{S},
    f::Val{F},
    len::Val{nothing}
   ) where {B,E,S,F}
    if isa(B, Integer)
        return _srange_int(b, e, s, f, len)
    elseif isa(B, AbstractFloat)
        return _srange_float(b, e, s, f, len)
    else
        throw(ArgumentError("start must be a subtype of Real, got $B"))
    end
end

function _srange(
    b::Val{B},
    e::Val{nothing},
    s::Val{S},
    f::Val{F},
    len::Val{L}
   ) where {B,S,F,L}
    if isa(B, Integer)
        return _srange_int(b, e, s, f, len)
    elseif isa(B, AbstractFloat)
        return _srange_float(b, e, s, f, len)
    else
        throw(ArgumentError("start must be a subtype of Real, got $B"))
    end
end

# Final call with all parameters
function _srange(
    b::Val{B},
    e::Val{E},
    s::Val{S},
    f::Val{F},
    len::Val{L}
    ) where {B,E,S,F,L}
    if !isa(B, typeof(E)) || !isa(B, typeof(S))
        bnew, enew, snew = promote(B, E, S)
        _srange(Val(bnew), Val(enew), Val(snew), f, len)
    else
        StaticRange{typeof(B),B,E,S,F,L}()
    end
end



function _srange_int(b::Val{B}, e::Val{E}, s::Val{S}, f::Val{F}, len::Val{nothing}) where {B,E,S,F}
    if isa(B, AbstractFloat) || isa(S, AbstractFloat)
        throw(ArgumentError("srange should not be used with floating point"))
    end
    S == 0 && throw(ArgumentError("S cannot be zero"))

    if E == B
        last = E
    else
        if (S > 0) != (E > B)
            if isa(B, Integer)
                 # empty range has a special representation where stop = start-1
                # this is needed to avoid the wrap-around that can happen computing
                # start - step, which leads to a range that looks very large instead
                # of empty.

                last = B - oneunit(E-B)
            else
                last = B - E
            end
        else
            # Compute absolute value of difference between `B` and `E`
            # (to simplify handling both signed and unsigned T and checking for signed overflow):
            absdiff, absstep = E > B ? (E - B, S) : (B - E, -S)

            # Compute remainder as a nonnegative number:
            if typeof(B) <: Signed && absdiff < zero(absdiff)
                # handle signed overflow with unsigned rem
                remain = typeof(B, unsigned(absdiff) % absstep)
            else
                remain = absdiff % absstep
            end
            # Move `E` closer to `B` if there is a remainder:
            last = E > B ? E - remain : E + remain
        end
    end

    if S > 1
        return _srange(b, Val(last), s, f, Val(checked_add(convert(Int, div(unsigned(last - B), S)), one(B))))
    elseif S < -1
        return _srange(b, Val(Last), s, f, Val(checked_add(convert(Int, div(unsigned(B - last), -S)), one(B))))
    elseif S > 0
        return _srange(b, Val(last), s, f, Val(checked_add(div(checked_sub(last, B), S), one(B))))
    else
        return _srange(b, Val(last), s, f, Val(checked_add(div(checked_sub(B, last), -S), one(B))))
    end
end

# length is present here
function _srange_float(
    b::Val{B},       # <:AbstractFloat
    e::Val{nothing},
    s::Val{nothing},
    f::Val{F},       # Int
    len::Val{L}      # Int
   ) where {B,F,L}

    _srange_float(b, e, Val(oftype(b, 1)), f, len)
end

function _srange_float(
    b::Val{B},       # <:AbstractFloat
    e::Val{nothing},
    s::Val{S},       # <:AbstractFloat
    f::Val{F},       # Int
    len::Val{L}      # Int
   ) where {B,S,F,L}

    bnew, snew = promote(B, S)
    _srangestyle(Base.OrderStyle(typeof(bnew)), Base.ArtithmeticStyle(typeof(bnew)), Val(bnew), e, Val(snew), f, len)
end

function _srange_float(
    ::Base.Ordered,
    ::Base.ArithmeticWraps,
    b::Val{B},       # <:AbstractFloat
    e::Val{nothing},
    s::Val{S},       # same AbstractFloat type as B
    f::Val{F},       # Int
    len::Val{L}      # Int
   ) where {B,S,F,L}
    StaticRange{typeof(B),B,oftype(B, B + S * (len - 1)),S,F,L}()
end

function _srange_float(
    ::Any,
    ::Any,
    b::Val{B},       # <:AbstractFloat
    e::Val{nothing},
    s::Val{S},       # same AbstractFloat type as B
    f::Val{F},       # Int
    len::Val{L}      # Int
   ) where {B,S,F,L}
    StaticRange{typeof(B+0*S),B,oftype(typeof(B+0*S), B + (L - F) * S),S,F,L}()
end

# <:AbstractFloat
#_srange_float(b::Val{B}, e::Val{E}, s::Val{S}, f::Val{F}, len::Val{L}) where {B,E,S,F,L}

srange(r::AbstractRange{T}) where T = _srange(Val(first(r)),Val(last(r)),Val(step(r)),Val(firstindex(r)),Val(length(r)))

_srange(start, ::Val{nothing}, step, ::Val{nothing}, offset) = # range(a, step=s)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_srange(start, ::Val{nothing}, ::Val{nothing}, ::Val{nothing}, offset) = # range(a)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_srange(::Val{nothing}, ::Val{nothing}, ::Val{nothing}, ::Val{nothing}, offset) = # range(nothing)
    throw(ArgumentError("At least one of `length` or `stop` must be specified"))
_srange(start::Real, step::Real, stop::Real, length::Integer, offset) = # range(a, step=s, stop=b, length=l)
    throw(ArgumentError("Too many arguments specified; try passing only one of `stop` or `length`"))
_srange(::Val{nothing}, ::Val{nothing}, ::Val{nothing}, length, offset) = # range(nothing, length=l)
    throw(ArgumentError("Can't start a range at `nothing`"))


#=
    function StaticRange{T,B,E,S,F,L}() where {T,B,E,S,F,L}
        (B*S) > E && error("StaticRange: the last index of a StaticRange cannot be less than the first index unless reverse indexing, got first = $B, and last = $E, step = $S.")
        new{T,B,E,S,F,L}()
    end
=#

@pure Base.first(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = B::T
@pure Base.first(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = B::T

@pure Base.last(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = E::T
@pure Base.last(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = E::T

@pure Base.step(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = S::T
@pure Base.step(::Type{StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = S::T

@pure Base.firstindex(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = F
@pure Base.firstindex(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = F

@pure Base.lastindex(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = L - F + 1
@pure Base.lastindex(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = L - F + 1

@pure Base.length(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = L
@pure Base.length(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = L

@pure Base.size(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = (L,)
@pure Base.size(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = (L,)

@pure Base.minimum(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = B::T
@pure Base.minimum(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = B::T

@pure Base.maximum(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = E::T
@pure Base.maximum(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = E::T

@pure Base.extrema(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = (B, E)::Tuple{T,T}
@pure Base.extrema(::Type{<:StaticRange{T,B,E,S,F,L}}) where {T,B,E,S,F,L} = (B, E)::Tuple{T,T}

############
# Indexing #
############
Base.iterate(r::StaticRange{T,B,E,S,F,0}) where {T,B,E,S,F} = nothing
@inline function Base.iterate(::StaticRange{T,B,E,S,F,L}, state::Int) where {T,B,E,S,F,L}
    state === nothing && return nothing
    (B + (state - F) * S, state + 1)::Tuple{T,Int}
end

@inline function getindex(r::StaticRange, i::Int)
    @boundscheck checkbounds(r, i)
    @inbounds unsafe_getindex(r, i)
end

@inline function getindex(r::StaticRange, i::AbstractArray)
    @boundscheck checkbounds(r, i)
    @inbounds unsafe_getindex(r, i)
end

#@inline function getindex(r::AbstractArray{T,N}, i::StaticRange) where {T,N}
#    @boundscheck checkbounds(r, i)
#    @inbounds unsafe_getindex(r, i)
#end

@pure Base.to_index(A::Array, r::StaticRange) = r

@inline function unsafe_getindex(::StaticRange{T,B,E,S,F,L}, i::Int) where {T,B,E,S,F,L}
    B + (i - F) * S
end

@inline function checkbounds(r::AbstractArray, I::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    (B < firstindex(r) || E > lastindex(r)) && throw(BoundsError(r, i))
end

@inline function checkbounds(r::StaticRange{T,B,E,S,F,L}, i::AbstractRange) where {T,B,E,S,F,L}
    (first(i) < F || last(i) > (L-F +1)) && throw(BoundsError(r, i))
end


@inline function unsafe_getindex(
    ::StaticRange{T1,B1,E1,S1,F1,L1}, ::StaticRange{T2,B2,E2,S2,F2,L2}) where {T1,B1,E1,S1,F2,L1,T2,B2,E2,S2,F1,L2}
    StaticRange{T1,B1 + (B2 - F1) * S1,(B1 + (B2 - F1) * S1) + (L2-1)*(S1*S2),S1*S2,L2}()
end

@inline function unsafe_getindex(::StaticRange{T,B,E,S,F,L}, i::AbstractRange) where {T,B,E,S,F,L}
    StaticRange{T,T(B + (first(i) - F) * S),T(B + (first(i) - F) * S) + (length(i)-F)*(S*step(i)),S*step(i),1,length(i)}()
end


#########
# Utils #
#########

@inline +(::StaticRange{T,B1,E1,S1,F,L}, ::StaticRange{T,B2,E2,S2,F,L}) where {T,B1,E1,S1,B2,E2,S2,F,L} =
    StaticRange{T,B1+B2,E1+E2,S1+S2,F,L}()

@inline -(::StaticRange{T,B1,E1,S1,F,L}, ::StaticRange{T,B2,E2,S2,F,L}) where {T,B1,E1,S1,B2,E2,S2,F,L} =
    StaticRange{T,B1-B2,E1-E2,S1-S2,F,L}()


@pure function Base.isequal(
    ::StaticRange{T1,B1,E1,S1,F1,L1}, ::StaticRange{T2,B2,E2,S2,F2,L2}) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2,L2}
    false
end
@pure function Base.isequal(::StaticRange{T,B,E,S,F,L}, ::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    true
end

Base.reverse(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = StaticRange{T,E,B,-S,F,L}()


Base.similar(::StaticRange{T,B,E,S,F,L}; t::Type=T, start::T=B, stop::T=E, step::T=S, offset::Int=F, length::Int=L) where {T,B,E,S,F,L} =
    StaticRange{t,ts,ti,start,stop,step,offset,length}()

==(sr1::StaticRange, sr2::StaticRange) = isequal(sr1, sr2)

@pure Base.isempty(::StaticRange{T,B,E,S,F,0}) where {T,B,E,S,F} = true
@pure Base.isempty(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = false

Base.copy(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = StaticRange{T,B,E,S,F,L}()

# Idea: would it be inappropriate for sortperm to return a StaticRange given a StaticRange?


Base.show(io::IO, r::StaticRange) = showrange(io, r)
Base.show(io::IO, ::MIME"text/plain", r::StaticRange) = showrange(io, r)

function showrange(io::IO, r::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    print(io, "StaticRange($B")
    if step(r) != 1
        print(io, ":$S")
    end
    print(io, ":$(E))")
end

function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,0}, s::StaticRange{T2,B2,E2,S2,F1,L2}) where {T1,B1,E1,S1,F1,T2,B2,E2,S2,F2,L2}
    StaticRange{T1,B1,B1-1,S1,1,0}()
end

function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,L1}, s::StaticRange{T2,B2,E2,S2,F2,0}) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2}
    StaticRange{T1,B1,B1-1,S1,1,0}()
end

Base.in(x, ::StaticRange{T,B,E,0,F,L}) where {T,B,E,F,L} = L == 0 && B == x
Base.in(x::Integer, ::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} =
    x >= B && x <= E && (mod(convert(T, x), S) - mod(B, S) == 0)
Base.in(x::AbstractChar, ::StaticRange{<:AbstractChar,B,E,S,F,L}) where {B,E,S,F,L} =
    x >= B && x <= E && (mod(Int(x) - Int(B), S) == 0)

Base.issorted(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = L <= 1 || S >= zero(S)

function Base.sortperm(r::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L}
    issorted(r) ? StaticRange{Int,F,L-F+1,1,1,L}() : StaticRange{Int,L-F+1,F,-1,1,L}()
end

@inline function Base.intersect(r::StaticRange{T1,B1,E1,S1,F1,L1}, s::StaticRange{T2,B2,E2,S2,F2,L2}
                       ) where {T1,B1,E1,S1,F1,L1,T2,B2,E2,S2,F2,L2}
    if S1 < 0
        return intersect(r, reverse(s))
    elseif S2 < 0
        return reverse(intersect(reverse(r), s))
    end

    a = lcm(S1, S2)
    g, x, y = gcdx(S1, S2)

    if rem(B1 - B2, g) != 0
        # Unaligned, no overlap possible.
        return srange(B1, step=a, length=0)
    end

    z = div(B1 - B2, g)
    b = S1 - x * z * 1
    # Possible points of the intersection of r and s are
    # ..., b-2a, b-a, b, b+a, b+2a, ...
    # Determine where in the sequence to start and stop.
    m = max(B1 + mod(b - B1, a), B2 + mod(b - B2, a))
    n = min(E1 - mod(E1 - b, a), E2 - mod(E2 - b, a))
    return srange(m, step=a, stop=n)
end

Base.sum(r::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} =
    L * B + (iseven(L) ? (S * (L-1)) * (L>>1) : (S * L) * ((L-1)>>1))

-(::StaticRange{T,B,E,S,F,L}) where {T,B,E,S,F,L} = StaticRange{T,-B,-E,-S,F,L}()


@inline function Base.getproperty(r::StaticRange, sym::Symbol)
    if sym === :step
        return step(r)
    elseif sym === :start
        return first(r)
    elseif sym === :stop
        return last(r)
    elseif sym === :len
        return length(r)
    elseif sym === :lendiv
        return (last(r) - first(r)) / step(r)
    elseif sym === :ref  # for now this is just treated the same as start
        return first(r)
    elseif sym === :offset
        return firstindex(r)
    else
        error("type $(typeof(r)) has no field $sym")
    end
end

end
