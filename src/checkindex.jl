
#= TODO this should be optimized and thoroughly inspected for ambiguities
Base.checkindex(::Type{Bool}, r::SRange, i) = _checkindex(Length(r), i)
_checkindex(::Length{L}, i::Integer) where {L} = (i < 1 || i > L) ? false : true
function _checkindex(::Length{L}, i::AbstractVector{<:Integer}) where {L}
    return minimum(i) < 1 || maximum(i) > L ? false : true
end
=#

checkindexlo(r, i::AbstractVector) = checkindexlo(r, minimum(i))
checkindexlo(r, i) = firstindex(r) <= i

checkindexhi(r, i::AbstractVector) = checkindexhi(r, maximum(i))
checkindexhi(r, i) = lastindex(r) >= i

Base.checkbounds(::Type{Bool}, gr::GapRange, i) = checkindex(Bool, gr, i)
function Base.checkindex(::Type{Bool}, gr::GapRange, i)
    return checkindexlo(gr, i) & checkindexhi(gr, i)
end

# TODO this needs to be in base
Base.isassigned(r::AbstractRange, i::Integer) = checkindex(Bool, r, i)

