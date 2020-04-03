
checkindexlo(r, i::AbstractVector) = checkindexlo(r, minimum(i))
checkindexlo(r, i) = firstindex(r) <= i
checkindexlo(r, i::CartesianIndex{1}) = firstindex(r) <= first(i.I)

checkindexhi(r, i::AbstractVector) = checkindexhi(r, maximum(i))
checkindexhi(r, i) = lastindex(r) >= i
checkindexhi(r, i::CartesianIndex{1}) = firstindex(r) <= first(i.I)


Base.checkbounds(::Type{Bool}, gr::GapRange, i) = checkindex(Bool, gr, i)
function Base.checkindex(::Type{Bool}, gr::GapRange, i)
    return checkindexlo(gr, i) & checkindexhi(gr, i)
end

# TODO this needs to be in base
Base.isassigned(r::AbstractRange, i::Integer) = checkindex(Bool, r, i)

