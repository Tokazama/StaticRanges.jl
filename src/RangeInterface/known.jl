
"""
    known_ref(::Type{T})

If `reference` of an instance of type `T` is known at compile time, return it. Otherwise,
return `nothing`. This specifically applies to ranges where there is on offset from the
from the first specified value, such as `StepRangeLen`.
"""
known_ref(x) = known_ref(typeof(x))
@inline function known_ref(::Type{T}) where {T}
    if parent_type(T) <: T
        return nothing
    else
        return known_ref(parent_type(T))
    end
end

"""
    known_offset(::Type{T})

If `offset` of an instance of type `T` is known at compile time, return it. Otherwise,
return `nothing`. This specifically applies to ranges where there is on offset from the
from the first specified value, such as `StepRangeLen`.
"""
known_offset(x) = known_offset(typeof(x))
function known_offset(::Type{T}) where {T}
    if has_parent(T)
        return known_offset(parent_type(T))
    else
        return nothing
    end
end


"""

    known_len(::Type{T})

If `len` of an instance of type `T` is known at compile time, return it. Otherwise,
return `nothing`. This specifically applies to ranges where the the length is specified
as part of construction such as `LinRange` and `StepRangeLen`
"""
known_len(x) = known_len(typeof(x))
function known_len(::Type{T}) where {T}
    if parent_type(T) <: T
        return nothing
    else
        return known_len(parent_type(T))
    end
end

"""

    known_lendiv(::Type{T})

If `lendiv` of an instance of type `T` is known at compile time, return it. Otherwise,
return `nothing`. This specifically applies to ranges where the the length is specified
as part of construction such as `LinRange` and `StepRangeLen`
"""
known_lendiv(x) = known_lendiv(typeof(x))
function known_lendiv(::Type{T}) where {T}
    if parent_type(T) <: T
        return nothing
    else
        return known_lendiv(parent_type(T))
    end
end

