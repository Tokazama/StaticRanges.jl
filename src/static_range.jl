

""" StaticRange{T,R} """
struct StaticRange{T,R} <: AbstractRange{T}

    function StaticRange{T,R}() where {T,R}
        @assert R <: AbstractRange
        @assert T <: eltype(R)
        return new{T,R}()
    end
    StaticRange{T}(x::StaticRange{T}) where {T} = x
    StaticRange{T}(x::AbstractRange{T}) where {T} = new{T,x}()
    function StaticRange(x::AbstractRange{T}) where {T}
        @assert !ismutable(x)
        return new{T,x}()
    end
end

srange(start; kwargs...) = StaticRange(range(start; kwargs...))
function srange(start, stop; kwargs...)
    if isempty(kwargs)
        return StaticRange(start:stop)
    else
        return StaticRange(range(start, stop; kwargs...))
    end
end

Static.known(::Type{StaticRange{T,R}}) where {T,R} = R
function Static.static(x::AbstractRange)
    if can_change_size(x)
        return as_static(as_fixed(x))
    else
        return StaticRange(x)
    end
end

Base.parent(::StaticRange{T,R}) where {T,R} = R

ArrayInterface.parent_type(::Type{StaticRange{T,R}}) where {T,R} = typeof(R)

@inline Base.getproperty(x::StaticRange, s::Symbol) = getproperty(parent(x), s)

Static.is_static(::Type{T}) where {T<:StaticRange} = True()

ArrayInterface.static_first(x::StaticRange) = static(known_first(x))
ArrayInterface.static_step(x::StaticRange) = static(known_step(x))
ArrayInterface.static_last(x::StaticRange) = static(known_last(x))

ArrayInterface.known_first(::Type{StaticRange{T,R}}) where {T,R} = first(R)
ArrayInterface.known_step(::Type{StaticRange{T,R}}) where {T,R} = step(R)
ArrayInterface.known_last(::Type{StaticRange{T,R}}) where {T,R} = last(R)
