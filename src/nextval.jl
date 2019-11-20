# TODO docs, out of bounds, errors
"""
    nextval(r::AbstractRange{T}, val::T, n::Integer=1) -> T

Return return the value that occurs `n` times after `val` in `r`.
"""
nextval(r::AbstractUnitRange{T}, val; n::Integer=1) where {T} = T(val + one(T) * n)
nextval(v::AbstractVector, val; n::Integer=1) = _nextval(Continuity(r), val, n)

function _nextval(::DiscreteTrait, v, val, n)
    error("Cannot use nextval on vector of discrete values.")
end

_nextval(::ContinuousTrait, v::AbstractVector{T}, val, n) where {T} = T(val + step(r) * n)


"""
    prevval(r::AbstractRange{T}, val::T, n::Integer=1) -> T

Return return the value that occurs `n` times before `val` in `r`.
"""
prevval(r::AbstractUnitRange{T}, val; n::Integer=1) where {T} = T(val - one(T) * n)
prevval(v::AbstractVector, val; n::Integer=1) = _prevval(Continuity(r), val, n)

function _prevval(::DiscreteTrait, v, val, n)
    error("Cannot use prevval on vector of discrete values.")
end

_prevval(::ContinuousTrait, v::AbstractVector{T}, val, n) where {T} = T(val - step(r) * n)
