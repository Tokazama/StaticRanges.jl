
"""
    Continuity
"""
abstract type Continuity end

struct ContinuousTrait <: Continuity end
const Continuous = ContinuousTrait()

struct DiscreteTrait <: Continuity end
const Discrete = DiscreteTrait()

Continuity(::T) where {T} = Continuity(T)
Continuity(::Type{T}) where {T} = Discrete
Continuity(::Type{T}) where {T<:AbstractRange} = Continuous

