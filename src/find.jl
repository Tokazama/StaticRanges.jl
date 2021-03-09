

function find_first_lt(val, x::AbstractRange)
    # must start at one
    if known_step(x) === nothing
        return _find_first_lt(val, x)
    else
        return _static_find_first_lt(val, x)
    end
end


_gt(x::X, y::Y) where {X,Y}


sdifelse(bool::Bool, sx, sy, dx, dy) = ifelse(bool, dx, dy)
sdifelse(::True, sx, sy, dx, dy) = sx
sdifelse(::False, sx, sy, dx, dy) = sy

maybe_ifelse(bool::Bool, x, y) = dynamic(ifelse(x, y))
maybe_ifelse(::True, x, y) = static(x)
maybe_ifelse(::False, x, y) = static(y)

maybe_eq(x, y)

function _static_find_first_lt()
end

wrap_static(::True, op, x) = static(op(x))

static_indicator(
ComposedFunction

staticop(f::F, x::X, y::Y) where {F,X,Y} = _staticop(is_static(X) & is_static(Y), f, x, y)
_staticop(::True, op, x, y) = static(op(x, y))
_staticop(::False, op, x, y) = op(x, y)

if_static(::True, x::X) where {X} = static(x)
if_static(::False, x::X) where {X} = x

function _find_first_lt(val, x)
    switch = is_static(step)
    if step > 0
        if start >= val
            return nothing
        else
            return if_static(switch & is_static(start) & is_static(val), 1)
        end
    else
        index = unsafe_find_value(x, collection)
        if lastindex(collection) <= index
            return nothing
        elseif firstindex(collection) > index
            return if_static(switch & is_static(index) & is_static(val), 1)
            return firstindex(collection)
        elseif @inbounds(collection[index]) < x
            return index
        else
            return index + oneunit(index)
        end
    end
end


