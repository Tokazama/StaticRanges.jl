const UnitSRangef16{B,E,L} = StaticRange{Float16,SVal{B,Float16},SVal{Float16(1),Float16},E,L,1}
const UnitSRangef32{B,E,L} = StaticRange{Float32,SVal{B,Float32},SVal{Float32(1),Float32},E,L,1}
const UnitSRangef64{B,E,L} = StaticRange{Float64,SVal{B,Float64},SVal{Float64(1),Float64},E,L,1}

const UnitSRangei128{B,E,L} = StaticRange{Int128,SVal{B,Int128},SVal{Int128(1),Int128},E,L,1}
const UnitSRangei64{B,E,L} = StaticRange{Int64,SVal{B,Int64},SVal{Int64(1),Int64},E,L,1}
const UnitSRangei32{B,E,L} = StaticRange{Int32,SVal{B,Int32},SVal{Int32(1),Int32},E,L,1}
const UnitSRangei16{B,E,L} = StaticRange{Int16,SVal{B,Int16},SVal{Int16(1),Int16},E,L,1}
const UnitSRangei8{B,E,L} = StaticRange{Int16,SVal{B,Int16},SVal{Int16(1),Int8},E,L,1}

const UnitSRangeui128{B,E,L} = StaticRange{UInt128,SVal{B,UInt128},SVal{UInt128(1),UInt128},E,L,1}
const UnitSRangeui64{B,E,L} = StaticRange{UInt64,SVal{B,UInt64},SVal{UInt64(1),UInt64},E,L,1}
const UnitSRangeui32{B,E,L} = StaticRange{UInt32,SVal{B,UInt32},SVal{UInt32(1),UInt32},E,L,1}
const UnitSRangeui16{B,E,L} = StaticRange{UInt16,SVal{B,UInt16},SVal{UInt16(1),UInt16},E,L,1}
const UnitSRangeui8{B,E,L} = StaticRange{UInt16,SVal{B,UInt16},SVal{UInt16(1),UInt8},E,L,1}

const UnitSRange{B,E,L} = Union{UnitSRangeui8{B,E,L},UnitSRangeui16{B,E,L},UnitSRangeui32{B,E,L},UnitSRangeui64{B,E,L},UnitSRangeui128{B,E,L},
                                UnitSRangei8{B,E,L},UnitSRangei16{B,E,L},UnitSRangei32{B,E,L},UnitSRangei64{B,E,L},UnitSRangei128{B,E,L},
                                UnitSRangef16{B,E,L},UnitSRangef32{B,E,L},UnitSRangef64{B,E,L}}

unitrange(b::SVal{B,T}, e::SVal{E,T}) where {B,E,T<:Real} = unitrange(T, b, e)
function unitrange(::Type{T}, b::SVal{B,Tb}, e::SVal{E,Te}) where {B,Tb,E,Te,T<:Real}
    enew = unitrange_last(b, e)
    SRange{T,SVal{B,Tb},SVal{T(1),T},get(enew),unitrange_length(b, enew),1}()
end

unitrange_last(b::SBool{B}, e::SBool{E}) where {B,E} = e
function unitrange_last(b::SInteger{B}, e::SInteger{E}) where {B,E}
    ifelse(E >= B, e, SVal{oftype(B, B-oneunit(E-B))}())
end

function unitrange_last(start::SVal{B,T}, stop::SVal{E,T}) where {B,E,T}
    if stop >= start
        (SVal{<:Any,T})(start+floor(stop-start))
    else
        (SVal{<:Any,T})(start-oneunit(stop-start))
    end
end

function unitrange_length(b::SVal{B,T}, e::SVal{E,T}) where {B,E,T<:Union{Int,Int64,Int128}}
    checked_add(checked_sub(E, B), one(T))
end
function unitrange_length(b::SVal{B,T}, e::SVal{E,T}) where {B,E,T<:Union{UInt,UInt64,UInt128}}
    E < B ? zero(T) : checked_add(E - B, one(T))
end

