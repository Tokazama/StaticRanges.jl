unitrange(b::SVal{B,T}, e::SVal{E,T}) where {B,E,T<:Real} = unitrange(T, b, e)
function unitrange(::Type{T}, b::SVal{B,Tb}, e::SVal{E,Te}) where {B,Tb,E,Te,T<:Real}
    SRange{T,SVal{B,Tb},SVal{T(1),T},E,unitrange_length(b, e),1}()
end

unitrange_last(b::SBool{B}, e::SBool{E}) where {B,E} = e
unitrange_last(b::SInteger{B}, e::SInteger{E}) where {B,E} = ifelse(E >= B, E, SVal{oftype(B, B-oneunit(E-B))}())
unitrange_last(b::SVal{B,T}, e::SVal{E,T}) where {T,B,E} = ifelse(E >= B, convert(T,B+floor(E-B)), convert(T,B-oneunit(E-B)))

unitrange_length(b::SVal{B,T}, e::SVal{E,T}) where {B,E,T<:Union{Int,Int64,Int128}} = checked_add(checked_sub(E, B), one(T))
unitrange_length(b::SVal{B,T}, e::SVal{E,T}) where {B,E,T<:Union{UInt,UInt64,UInt128}} = E < B ? zero(T) : checked_add(E - B, one(T))
