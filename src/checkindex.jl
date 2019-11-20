
Base.checkindex(::Type{Bool}, r::SRange, i) = _checkindex(Length(r), i)
_checkindex(::Length{L}, i::Integer) where {L} = (i < 1 || i > L) ? false : true
function _checkindex(::Length{L}, i::AbstractVector{<:Integer}) where {L}
    return minimum(i) < 1 || maximum(i) > L ? false : true
end
