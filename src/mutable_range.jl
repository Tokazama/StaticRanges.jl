
""" MutableRange """
mutable struct MutableRange{T,P<:AbstractRange{T}} <:AbstractRange{T}
    parent::P
end


mrange(start; kwargs...) = MutableRange(range(start; kwargs...))
function mrange(start, stop; kwargs...)
    if isempty(kwargs)
        return MutableRange(start:stop)
    else
        return MutableRange(range(start, stop; kwargs...))
    end
end

const UnitMRange{T} = MutableRange{T,UnitRange{T}}
const StepMRange{T,S} = MutableRange{T,StepRange{T,S}}
const StepMRangeLen{T,R,S} = MutableRange{T,StepRangeLen{T,R,S}}
const LinMRange{T} = MutableRange{T,LinRange{T}}

const MRange = Union{DynamicAxis,MutableRange}

ArrayInterface.can_change_size(::Type{T}) where {T<:MutableRange} = true

Base.reverse!(r::MutableRange) = setfield!(r, :parent, reverse(parent(r)))
Base.sort!(r::MutableRange) = setfield!(r, :parent, sort(parent(r)))

Base.isempty(r::MutableRange) = isempty(parent(r))

Base.empty!(r::MutableRange) = setfield!(r, :parent, empty(r))

_empty(r::LinRange) = LinRange(first(r), last(r), 0)
_empty(r::StepRangeLen) = StepRangeLen(r.ref, r.step, 0, r.offset)
_empty(r::StepRange)  = StepRange(r.start, r.step, r.start - step(r))
_empty(r::UnitRange{T}) where {T} = UnitRange(first(r), first(r) - one(T))
_empty(r::OneTo{T}) where {T} = OneTo(zero(T))


Base.parent(x::MutableRange) = getfield(x, :parent)

ArrayInterface.parent_type(::Type{MutableRange{T,R}}) where {T,R} = R

@inline Base.getproperty(x::MutableRange, s::Symbol) = getproperty(parent(x), s)


function Base.promote_rule(::Type{T1}, ::Type{T2}) where {T1<:MutableRange,T2<:MutableRange}
    return promote_rule(parent_type(T1), parent_type(T2))
end

