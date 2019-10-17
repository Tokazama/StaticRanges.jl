

struct IsStaticTrait end
const IsStatic = IsStaticTrait

struct IsNotStaticTrait end
const IsNotStatic = IsNotStaticTrait()

StaticTrait(::T) where {T} = StaticTrait(T)
StaticTrait(::Type{T}) where {T} = IsNotStatic
StaticTrait(::Type{T}) where {T<:Val} = IsStatic

"""
    isstatic(x) -> Bool

Returns `true` if `x` is static.
"""
isstatic(::X) where {X} = isstatic(X)
isstatic(::Type{X}) where {X} = false


"""
    setfirst!(x, val)

Set the first element of `x` to `val`.
"""
function setfirst!(x, val)
    if can_grow_first(x)
        @inbounds setindex!(x, val, firstindex(x))
    else
        throw(MethodError(setfirst!, (x, val)))
    end
end

"""
    setlast!(x, val)

Set the last element of `x` to `val`.
"""
function setlast!(x, val)
    can_grow_last(x) || throw(MethodError(setlast!, (x, val)))
    @inbounds return setindex!(x, val, lastindex(x))
end


"""
    has_step(x) -> Bool

Returns `true` if type of `x` has `step` method defined.
"""
has_step(::X) where {X} = has_step(X)
has_step(::Type{T}) where {T} = false
has_step(::Type{T}) where {T<:AbstractRange} = true

"""
    can_setstep(x) -> Bool
"""
can_setstep(::X) where {X} = can_setstep(X)
can_setstep(::Type{X}) where {X} = false

"""
    setstep!(x, val)

Sets the `step` of `x` to `val`.
"""
function setstep!(x, val)
    if can_setstep(x)
        setproperty!(x, :step, val)
    else
        throw(MethodError(setstep!, (x, val)))
    end
end


