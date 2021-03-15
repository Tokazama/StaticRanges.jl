###
### iterate
###
checkindexlo(r, i::AbstractVector) = checkindexlo(r, minimum(i))
checkindexlo(r, i) = firstindex(r) <= i
checkindexlo(r, i::CartesianIndex{1}) = firstindex(r) <= first(i.I)

checkindexhi(r, i::AbstractVector) = checkindexhi(r, maximum(i))
checkindexhi(r, i) = lastindex(r) >= i
checkindexhi(r, i::CartesianIndex{1}) = firstindex(r) <= first(i.I)

###
### Generic array traits
###
# TODO should this be in Static.jl
static_isempty(x::OrdinalRange) = _static_isempty(static_first(x), static_step(x), static_last(x))
function static_isempty(x)
    len = static_length(x)
    return Static.eq(zero(len), len)
end
function _static_isempty(start::F, step::S, stop::L) where {F,S,L}
    return Static.ne(start, stop) & Static.ne(Static.gt(step, zero(step)), Static.gt(stop, start))
end

# FIXME these absolutely needs to go in ArrayInterface
function ArrayInterface.known_length(::Type{T}) where {T<:AbstractRange}
    if parent_type(T) <: T
        return nothing
    else
        return known_length(parent_type(T))
    end
end

#Base.rem(::Static.StaticFloat64{X}, ::Static.StaticFloat64{Y}) where {X,Y} = static(rem(X, Y))
static_div(x::X, y::Y) where {X,Y} = _div(is_static(X) & is_static(Y), x, y)
_div(::True, x, y) = static(div(known(x), known(y)))
_div(::False, x, y) = div(dynamic(x), dynamic(y))

static_rem(x::X, y::Y) where {X,Y} = _rem(is_static(X) & is_static(Y), x, y)
_rem(::True, x, y) = static(rem(known(x), known(y)))
_rem(::False, x, y) = rem(dynamic(x), dynamic(y))

_sub1(x::T) where {T} = x - oneunit(T)
_add1(x::T) where {T} = x + oneunit(T)
_int(idx) = round(Integer, idx, RoundToZero)::Int
_int(idx::Integer) = Int(idx)::Int
_int(idx::StaticInt{N}) where {N} = idx
_int(idx::TwicePrecision{T}) where {T} = round(Integer, T(idx), RoundToZero)

_drop_unit(x::X) where {X} = div(x, oneunit(x))
_drop_unit(x::Real) = x

### empty
_empty_ur(::Type{T}) where {T} = one(T):zero(T)

_empty(x::X, y::Y) where {X,Y} = Vector{Int}()
@inline function _empty(x::X, y::Y) where {X<:AbstractRange,Y<:AbstractRange}
    if (known_step(X) === nothing) | (known_step(Y) === nothing)
        return 1:1:0
    else
        if known_first(x) === one(eltype(X))  && known_first(y) === one(eltype(Y))
            if known_last(x) isa Nothing || known_last(y) isa Nothing
                return static(1):0
            else
                return static(1):static(0)
            end
        else
            return 1:0
        end
    end
end

const Equal{T} = Union{Fix2{typeof(==),T},Fix2{typeof(isequal),T}}
const NotEqual{T} = Fix2{typeof(!=),T}
const NotIn{T} = (typeof(!in(Any)).name.wrapper){Fix2{typeof(in),T}}
const In{T} = Fix2{typeof(in),T}

_maybe_static(::True, x::Int) = static(x)
_maybe_static(::True, x::StaticInt) = x
_maybe_static(::False, x::Int) = x
_maybe_static(::False, x::StaticInt) = dynamic(x)


ifelseop(::True, t, f, args...) = t(args...)
ifelseop(::False, t, f, args...) = f(args...)
@inline function ifelseop(b::Bool, t, f, args...)
    if b
        return dynamic(t(args...))
    else
        return dynamic(f(args...))
    end
end

return_nothing(args...) = nothing

return_static_one(args...) = static(1)

ifadd1(x, val) = ifelseop(x, _add1, identity, val)
ifsub1(x, val) = ifelseop(x, _sub1, identity, val)

_static_length(_, r) = static_length(r)
_static_length(_, _, r) = static_length(r)


