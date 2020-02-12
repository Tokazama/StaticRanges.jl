# TODO reverse indexing (e.g., reverse(::AxisIndices))
Base.IteratorSize(::Type{<:AxisIndices{<:Any,N}}) where {N} = Base.HasShape{N}()

@inline function Base.iterate(iter::CartesianAxes)
    iterfirst, iterlast = first(iter), last(iter)
    if any(map(>, iterfirst, iterlast))
        return nothing
    else
        return iterfirst, iterfirst
    end
end
@inline function Base.iterate(iter::AxisIndices, state::Tuple)
    valid, I = __inc(state, first(iter), last(iter))
    if valid
        _maybe_linear(iter, I)
    else
        return nothing
    end
end

Base.iterate(x::LinearAxes, i=1) = i > length(x) ? nothing : (i, i+one(i))
function _maybe_linear(iter::LinearAxes, I::Tuple)
    newstate = to_linear(iter, axes(iter), I)
    return newstate, newstate
end
_maybe_linear(iter::AxisIndices, I::Tuple) = I, I


# increment & carry
@inline function inc(state, start, stop)
    _, I = __inc(state, start, stop)
    return I
end

# increment post check to avoid integer overflow
@inline __inc(::Tuple{}, ::Tuple{}, ::Tuple{}) = false, ()
@inline function __inc(state::Tuple{Int}, start::Tuple{Int}, stop::Tuple{Int})
    return first(state) < first(stop), (first(state) + 1,)
end

@inline function __inc(state, start, stop)
    if first(state) < first(stop)
        return true, (first(state) + 1, tail(state)...)
    else
        valid, I = __inc(tail(state), tail(start), tail(stop))
        return valid, (first(start), I...)
    end
end

# decrement & carry
@inline function dec(state, start, stop)
    _, I = __dec(state, start, stop)
    return I
end

# decrement post check to avoid integer overflow
@inline __dec(::Tuple{}, ::Tuple{}, ::Tuple{}) = false, ()
@inline function __dec(state::Tuple{Int}, start::Tuple{Int}, stop::Tuple{Int})
    return first(state) > first(stop), (first(state) - 1,)
end

@inline function __dec(state, start, stop)
    if first(state) > first(stop)
        return true, (first(state) - 1, tail(state)...)
    else
        valid, I = __dec(tail(state), tail(start), tail(stop))
        return valid, (first(start), I...)
    end
end

function Base.nextind(A::AxisIndices{<:Any,N}, i::Tuple{Vararg{<:Any,N}}) where {N}
    return inc(i, map(first, axes(A)), map(last, axes(A)))
end

function Base.prevind(A::AxisIndices{<:Any,N}, i::Tuple{Vararg{<:Any,N}}) where {N}
    return dec(i, map(last, axes(A)), map(first, axes(A)))
end

#Base.to_shape(x::Tuple{Vararg{<:AbstractAxis}}) = Base.to_shape()
#map(to_shape, dims)::DimsOrInds

function Base.collect(A::AxisIndices)
    B = Array{eltype(A)}(undef, size(A))
    copyto!(B, CartesianAxes(axes(B)), A, A)
    return B
end

# TODO it might be worth just doing all of this with Transducers.jl eventually
function Base.copyto!(dest::AbstractArray{T1,N}, Rdest::AxisIndices{<:Any,N},
                  src::AbstractArray{T2,N}, Rsrc::AxisIndices{<:Any,N}) where {T1,T2,N}
    isempty(Rdest) && return dest
    if size(Rdest) != size(Rsrc)
        throw(ArgumentError("source and destination must have same size (got $(size(Rsrc)) and $(size(Rdest)))"))
    end
    checkbounds(dest, first(Rdest)...)
    checkbounds(dest, last(Rdest)...)
    checkbounds(src, first(Rsrc)...)
    checkbounds(src, last(Rsrc)...)
    src′ = Base.unalias(dest, src)
    ΔI = first(Rdest) .- first(Rsrc)
    if @generated
        quote
            @nloops $N i (n->axes(Rsrc, n)) begin
                @inbounds @nref($N, dest, n -> i_n + ΔI[n]) = @nref($N, src′,i)
            end
        end
    else
        for I in Rsrc
            @inbounds dest[I + ΔI] = src′[I]
        end
    end
    dest
end
