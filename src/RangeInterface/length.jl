
"""
    known_length(::Type{T})

If `length` of an instance of type `T` is known at compile time, return it. Otherwise,
return `nothing`.
"""
known_length(x) = known_length(typeof(x))
known_length(::Type{T}) where {T} = nothing
function known_length(::Type{T}) where {T<:AbstractRange}
    if has_len_field(T)
        return nothing # this must be set for individual type
    else
        if step_is_known_one(T)
            if first_is_known_one(T)
                return one_to_length(known_last(T))
            else
                return unit_range_length(known_first(T), known_last(T))
            end
        else
            return known_len(T)
        end
    end
end

###
### get_length - generic way of getting length if parent type is range
###
@inline function get_length(x::X) where {X}
    if isempty(x)
        return 0
    else
        return unsafe_length(x)
    end
end

@inline function unsafe_length(x::X) where {X}
    if is_range(X)
        if has_len_field(X)
            return get_len_field(x)
        else
            if has_start_field(X)
                if has_step_field(X)
                    return step_range_length(x)
                else
                    return unit_range_length(x)
                end
            else
                return one_to_length(x) 
            end
        end
    else
        return length(x)
    end
end

###
### StepRange
###
@inline function step_range_length(x)
    len = step_range_length(eltype(x), known_first(x), known_step(x), known_last(x))
    if len isa Nothing
        return step_range_length(eltype(x), first(x), step(x), last(x))
    else
        return len
    end
end

@inline function step_range_length(::Type{T}, start, step, stop) where {T}
    if start isa Nothing
        return nothing
    else
        if (start != stop) & ((step > zero(step)) != (stop > start))
            return 0
        else
            return Int(div((stop - start) + step, step))
        end
    end
end

@inline function step_range_length(::Type{T}, start, step, stop) where {T<:Union{Int,UInt,Int64,UInt64,Int128,UInt128}}
    if start isa Nothing
        return nothing
    else
        if (start != stop) & ((step > zero(step)) != (stop > start))
            return 0
        elseif step > 1
            return Int(div(unsigned(stop - start), step)) + 1
        elseif step < -1
            return Int(div(unsigned(start - stop), -step)) + 1
        elseif step > 0
            return Int(div(stop - start, step) + 1)
        else
            return Int(div(start - stop, -step) + 1)
        end
    end
end


###
### UnitRange
###
@inline function unit_range_length(x)
    len = unit_range_length(known_first(x), known_last(x))
    if len isa Nothing
        return unit_range_length(first(x), last(x))
    else
        return len
    end
end

@inline function unit_range_length(start::T, stop::T) where {T<:Union{Int,Int64,Int128}}
    return Int(Base.Checked.checked_add(stop - start, one(T)))
end

@inline function unit_range_length(start::T, stop::T) where {T<:Union{UInt,UInt64,UInt128}}
    return Int(Base.Checked.checked_add(Base.Checked.checked_sub(stop, start), one(T)))
end

@inline unit_range_length(start::T, stop::T) where {T} = Integer(stop - start + 1)

unit_range_length(::Nothing, ::Nothing) = nothing

###
### OneTo
###
@inline function one_to_length(x::AbstractVector{T}) where {T}
    lst = one_to_length(known_last(x))
    if lst isa Nothing
        return last(x)
    else
        return lst
    end
end

one_to_length(::Nothing) = nothing
one_to_length(x::Integer) = x

