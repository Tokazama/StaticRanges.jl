
function Base.getindex(r::Union{AbstractStepRangeLen,AbstractLinRange}, i::Integer)
    Base.@_inline_meta
    @boundscheck checkbounds(r, i)
    unsafe_getindex(r, i)
end

function Base.iterate(r::Union{AbstractLinRange,AbstractStepRangeLen}, i::Int=1)
    Base.@_inline_meta
    length(r) < i && return nothing
    unsafe_getindex(r, i), i + 1
end

Base.isempty(r::Union{AbstractLinRange,AbstractStepRangeLen}) = length(r) == 0

#= TODO

==(r::T, s::T) where {T<:AbstractRange} =
    (first(r) == first(s)) & (step(r) == step(s)) & (last(r) == last(s))
==(r::OrdinalRange, s::OrdinalRange) =
    (first(r) == first(s)) & (step(r) == step(s)) & (last(r) == last(s))
==(r::T, s::T) where {T<:Union{StepRangeLen,LinRange}} =
    (first(r) == first(s)) & (length(r) == length(s)) & (last(r) == last(s))
==(r::Union{StepRange{T},StepRangeLen{T,T}}, s::Union{StepRange{T},StepRangeLen{T,T}}) where {T} =
    (first(r) == first(s)) & (last(r) == last(s)) & (step(r) == step(s))
=#

function promote_rule(::Type{LinRange{L}}, b::Type{StepRangeLen{T,R,S}}) where {L,T,R,S}
    promote_rule(StepRangeLen{L,L,L}, b)
end

#=
$f(r1::Union{StepRangeLen, OrdinalRange, LinRange},
   r2::Union{StepRangeLen, OrdinalRange, LinRange}) =
       $f(promote(r1, r2)...)

Base.:(==)(r::T, s::T) where {T<:Union{StepRangeLen,LinRange}} =
    (first(r) == first(s)) & (length(r) == length(s)) & (last(r) == last(s))
=#
