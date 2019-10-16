
"""
    isstatic(x) -> Bool
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

function start_step_stop_to_length(::Type{T}, start, step, stop) where {T}
    return Integer(div((stop - start) + step, step))
end


function start_step_stop_to_length(
    ::Type{T},
    start,
    step,
    stop
   ) where {T<:Union{Int,UInt,Int64,UInt64,Int128,UInt128}}
    # TODO isempty(r) && return zero(T)
    if step > 1
        return (convert(T, div(unsigned(stop - start), step)) + one(T))
    elseif step < -1
        return (convert(T, div(unsigned(start - stop), -step)) + one(T))
    elseif step > 0
        return (div(stop - start, step) + one(T))
    else
        return (div(start - stop, -step) + one(T))
    end
end
