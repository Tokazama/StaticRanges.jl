# this allows us to known the underlying range type if it's wrapped by another type


step_type(x) = step_type(typeof(x))
step_type(::Type{StepRangeLen{T,R,S}}) where {T,R,S} = S
step_type(::Type{<:OrdinalRange{T,S}}) where {T,S} = S
function step_type(::Type{T}) where {T}
    if has_parent(T)
        return step_type(parent_type(T))
    else
        return eltype(T)
    end
end

ref_type(x) = ref_type(typeof(x))
ref_type(::Type{StepRangeLen{T,R,S}}) where {T,R,S} = R
function ref_type(::Type{T}) where {T}
    if has_parent(T)
        return ref_type(parent_type(T))
    else
        return eltype(T)
    end
end

# TODO document has_ref_field
has_ref_field(x) = has_ref_field(typeof(x))
has_ref_field(::Type{T}) where {T<:StepRangeLen} = true
function has_ref_field(::Type{T}) where {T}
    if has_parent(T)
        return has_ref_field(parent_type(T))
    else
        return false
    end
end


# TODO document has_len_field
has_len_field(x) = has_len_field(typeof(x))
has_len_field(::Type{T}) where {T<:LinRange} = true
has_len_field(::Type{T}) where {T<:StepRangeLen} = true
function has_len_field(::Type{T}) where {T}
    if has_parent(T)
        return has_len_field(parent_type(T))
    else
        return false
    end
end

# TODO document has_lendiv_field
has_lendiv_field(x) = has_lendiv_field(typeof(x))
has_lendiv_field(::Type{T}) where {T<:LinRange} = true
function has_lendiv_field(::Type{T}) where {T}
    if has_parent(T)
        return has_lendiv_field(parent_type(T))
    else
        return false
    end
end

# TODO document has_offset_field
has_offset_field(x) = has_offset_field(typeof(x))
has_offset_field(::Type{T}) where {T<:StepRangeLen} = true
function has_offset_field(::Type{T}) where {T}
    if has_parent(T)
        return has_offset_field(parent_type(T))
    else
        return false
    end
end

# TODO document has_offset_field
has_step_field(x) = has_step_field(typeof(x))
has_step_field(::Type{T}) where {T<:StepRangeLen} = true
has_step_field(::Type{T}) where {T<:StepRange} = true
function has_step_field(::Type{T}) where {T}
    if has_parent(T)
        return has_step_field(parent_type(T))
    else
        return false
    end
end

# TODO document has_offset_field
has_start_field(x) = has_start_field(typeof(x))
has_start_field(::Type{T}) where {T<:StepRange} = true
has_start_field(::Type{T}) where {T<:UnitRange} = true
has_start_field(::Type{T}) where {T<:LinRange} = true
@inline function has_start_field(::Type{T}) where {T}
    if has_parent(T)
        return has_start_field(parent_type(T))
    else
        return false
    end
end

# TODO document has_offset_field
has_stop_field(x) = has_stop_field(typeof(x))
has_stop_field(::Type{T}) where {T<:StepRange} = true
has_stop_field(::Type{T}) where {T<:UnitRange} = true
has_stop_field(::Type{T}) where {T<:LinRange} = true
has_stop_field(::Type{T}) where {T<:OneTo} = true
function has_stop_field(::Type{T}) where {T}
    if has_parent(T)
        return has_stop_field(parent_type(T))
    else
        return false
    end
end


"""
    get_lendiv_field(x)

Return the field `len` of range `x`. This permits returning this field if `x` is vector
that wraps a range with this field.
"""
@inline function get_lendiv_field(x)
    if has_parent(x)
        return get_lendiv(parent(x))
    elseif has_lendiv_field(x)
        if is_static(x)
            return known_lendiv(x)
        else
            return getfield(x, :lendiv)
        end
    else
        return throw(MethodError(get_lendiv_field, (x,)))
    end
end

@inline function set_lendiv_field!(x, val)
    if has_parent(x)
        return set_lendiv_field!(parent(x), val)
    elseif has_lendiv_field(x)
        return setfield!(x, :lendiv, Int(val))
    else
        return throw(MethodError(set_lendiv_field!, (x,)))
    end
end




"""
    get_len_field(x)

Return the field `len` of range `x`. This permits returning this field if `x` is vector
that wraps a range with this field.
"""
function get_len_field(x)
    if has_parent(x)
        return get_len_field(parent(x))
    elseif has_len_field(x)
        if is_static(x)
            return known_len(x)
        else
            return getfield(x, :len)
        end
    else
        return throw(MethodError(get_len_field, (x,)))
    end
end

function set_len_field!(x, val)
    if has_parent(x)
        return set_len_field!(parent(x), val)
    elseif has_len_field(x)
        return setfield!(x, :len, Int(val))
    else
        return throw(MethodError(set_len_field!, (x,)))
    end
end


"""
    get_offset_field(x)

Return the `offset` of `x` from zero.
"""
function get_offset_field(x)
    if has_parent(x)
        return get_offset_field(parent(x))
    elseif has_offset_field(x)
        if is_static(x)
            return known_offset(x)
        else
            return getfield(x, :offset)
        end
    else
        return firstindex(x)
    end
end

function set_offset_field!(x, val)
    if has_parent(x)
        return set_offset_field!(parent(x), val)
    elseif has_offset_field(x)
        return setfield!(x, :offset, Int(val))
    else
        return throw(MethodError(set_offset_field!, (x,)))
    end
end

"""
    get_step_field(x)

Return the field `step` of range `x`. This permits returning this field if `x` is vector
that wraps a range with this field.
"""
function get_step_field(x)
    if has_parent(x)
        return get_step(parent(x))
    elseif has_step_field(x)
        if is_static(x)
            return known_step(x)
        else
            return getfield(x, :step)
        end
    else
        return throw(MethodError(get_step_field, (x, val)))
    end
end

function set_step_field!(x, val)
    if has_parent(x)
        return set_step_field!(parent(x), val)
    elseif has_step_field(x)
        return setfield(x, :step, convert(set_type(x), val))
    else
        return throw(MethodError(set_step_field!, (x, val)))
    end
end


"""
    get_start_field(x)

Return the field `start` of range `x`. This permits returning this field if `x` is vector
that wraps a range with this field.
"""
function get_start_field(x)
    if has_parent(x)
        return get_start_field(parent(x))
    elseif has_start_field(x)
        if is_static(x)
            return known_first(x)
        else
            return getfield(x, :start)
        end
    else
        return throw(MethodError(get_start_field, (x,)))
    end
end

function set_start_field!(x, val)
    if has_parent(x)
        return set_start_field!(parent(x), val)
    elseif has_start_field(x)
        return setfield!(x, :start, convert(eltype(x), val))
    else
        return throw(MethodError(set_start_field!, (x, val)))
    end
end

"""
    get_stop_field(x)

Return the field `stop` of range `x`. This permits returning this field if `x` is vector
that wraps a range with this field.
"""
function get_stop_field(x)
    if has_parent(x)
        return get_stop_field(parent(x))
    elseif has_stop_field(x)
        if is_static(x)
            return known_last(x)
        else
            return getfield(x, :stop)
        end
    else
        return throw(MethodError(get_stop_field, (x,)))
    end
end

function set_stop_field!(x, val)
    if has_parent(x)
        return set_stop_field!(parent(x), val)
    elseif has_stop_field(x)
        return setfield!(x, :stop, convert(eltype(x), val))
    else
        return throw(MethodError(set_stop_field!, (x, val)))
    end
end

function get_ref_field(x)
    if has_parent(x)
        return get_reference_field(parent(x))
    elseif has_ref_field(x)
        if is_static(x)
            return known_ref(x)
        else
            return getfield(x, :ref)
        end
    else
        return throw(MethodError(get_ref_field, (x,)))
    end
end

function set_ref_field!(x, val)
    if has_parent(x)
        return set_ref_field!(parent(x), val)
    elseif has_ref_field(x)
        return setfield!(x, :ref, convert(ref_type(x), val))
    else
        return throw(MethodError(set_stop_field!, (x, val)))
    end
end


