
"""
    DynamicAxis

A mutable range that parallels `OneTo` in behavior.
"""
mutable struct DynamicAxis <: AbstractUnitRange{Int}
    stop::Int

    DynamicAxis(stop::Real) = new(Int(max(0, stop)))

    function DynamicAxis(r::AbstractRange)
        first(r) == 1 || (Base.@_noinline_meta; throw(ArgumentError("first element must be 1, got $(first(r))")))
        step(r)  == 1 || (Base.@_noinline_meta; throw(ArgumentError("step must be 1, got $(step(r))")))
        return DynamicAxis(last(r))
    end
end

Base.first(::DynamicAxis) = 1

Base.last(r::DynamicAxis) = getfield(r, :stop)
Base.length(x::DynamicAxis) = last(x)
Base.lastindex(r::DynamicAxis) = last(r)::Int

Base.issubset(r::DynamicAxis, s::OneTo) = last(r) <= last(s)
Base.issubset(r::DynamicAxis, s::DynamicAxis) = last(r) <= last(s)
Base.issubset(r::OneTo, s::DynamicAxis) = last(r) <= last(s)

Base.mod(i::Integer, r::DynamicAxis) = Base.mod1(i, last(r))

function Base.setproperty!(x::DynamicAxis, s::Symbol, val)
    error("cannot use setproperty! on DynamicAxis")
end

Base.intersect(r::DynamicAxis, s::DynamicAxis) = OneTo(min(last(r),last(s)))
Base.intersect(r::DynamicAxis, s::OneTo) = OneTo(min(last(r),last(s)))
Base.intersect(r::OneTo, s::DynamicAxis) = OneTo(min(last(r),last(s)))

Base.show(io::IO, r::DynamicAxis) = print(io, "DynamicAxis($(last(r)))")


Base.:(==)(r::DynamicAxis, s::DynamicAxis) = last(r) === last(s)
Base.:(==)(r::OneTo, s::DynamicAxis) = last(r) === last(s)
Base.:(==)(r::DynamicAxis, s::OneTo) = last(r) == last(s)

Base.empty!(r::DynamicAxis) = (setfield!(r, :stop, 0); r)

Base.in(x::Integer, r::DynamicAxis) = !(1 > x) & !(x > last(r))

function Base.in(x::Real, r::DynamicAxis)
    val = round(Integer, x)
    if in(val, r)
        return @inbounds(getindex(r, val)) == x
    else
        return false
    end
end

function Base.Broadcast.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::DynamicAxis, x::Number)
    return range(first(r)-x, length=length(r))
end

Base.Broadcast.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::DynamicAxis) = r

###
### ArrayInterface
###
ArrayInterface.can_change_size(::Type{DynamicAxis}) = true
ArrayInterface.known_first(::Type{DynamicAxis}) = 1
ArrayInterface.known_step(::Type{DynamicAxis}) = 1

@propagate_inbounds function Base.getindex(v::DynamicAxis, i::Integer)
    @boundscheck ((i > 0) & (i <= last(v))) || throw(BoundsError(v, i))
    return Int(i)
end

@propagate_inbounds function Base.getindex(r::DynamicAxis, s::OneTo)
    @boundscheck checkbounds(r, s)
    return OneTo(Int(last(s)))
end

Base.AbstractUnitRange{Int}(r::DynamicAxis) = DynamicAxis(r)

Base.promote_rule(::Type{DynamicAxis}, ::Type{OneTo{T}}) where {T} = OneTo{promote_type(T,Int)}
Base.promote_rule(::Type{OneTo{T}}, ::Type{DynamicAxis}) where {T} = OneTo{promote_type(T,Int)}


#=
Base.promote_rule(a::Type{UnitMRange{T1}}, b::Type{DynamicAxis{T2}}) where {T1,T2} = UnitMRange{promote_type(T1,T2)}
Base.promote_rule(a::Type{DynamicAxis}, b::Type{UnitMRange{T2}}) where {T1,T2} = UnitMRange{promote_type(T1,T2)}
=#

function unsafe_grow_end!(x::DynamicAxis, n)
    setfield!(x, :stop, Int(n + last(x)))
    return x
end

function unsafe_shrink_end!(x::DynamicAxis, n)
    setfield!(x, :stop, Int(n - last(x)))
    return x
end

