is_static(::Type{IdOffsetRange{T,P}}) where {T,P} = is_static(P)
is_fixed(::Type{IdOffsetRange{T,P}}) where {T,P} = is_fixed(P)

as_dynamic(x::IdOffsetRange) = IdOffsetRange(as_dynamic(parent(x)), x.offset)
as_fixed(x::IdOffsetRange) = IdOffsetRange(as_fixed(parent(x)), x.offset)
as_static(x::IdOffsetRange) = IdOffsetRange(as_static(parent(x)), x.offset)

can_set_first(::Type{<:IdOffsetRange{T,P}}) where {T,P} = can_set_first(P)
function set_first(r::IdOffsetRange{T}, val::T) where {T}
    return IdOffsetRange(set_first(parent(r), val), r.offset)
end
function set_first!(r::IdOffsetRange{T}, val::T) where {T}
    set_first!(parent(r), val)
    return r
end

can_set_last(::Type{<:IdOffsetRange{T,P}}) where {T,P} = can_set_last(P)
function set_last(r::IdOffsetRange{T}, val::T) where {T}
    return IdOffsetRange(set_last(parent(r), val), r.offset)
end
function set_last!(r::IdOffsetRange{T}, val::T) where {T}
    set_last!(parent(r), val)
    return r
end

can_set_length(::Type{<:IdOffsetRange{T,P}}) where {T,P} = can_set_length(P)
function set_length(r::IdOffsetRange{T}, len) where {T}
    return IdOffsetRange(set_length(parent(r), len), r.offset)
end
function set_length!(r::IdOffsetRange{T}, len) where {T}
    set_length!(parent(r), len)
    return r
end

