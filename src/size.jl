
Base.size(gr::GapRange) = (length(gr),)

StaticArrays.Size(::Type{LinSRange{T,B,E,L,D}}) where {T,B,E,L,D} = Size{(L,)}()

StaticArrays.Size(::Type{StepSRangeLen{T,Tr,Ts,R,S,L,F}}) where {T,Tr,Ts,R,S,L,F} = Size{(L,)}()

function StaticArrays.Size(::Type{StepSRange{T,Ts,F,S,L}})  where {T,Ts,F,S,L}
    return Size{(RangeInterface.step_range_length(T, F, S, L),)}()
end

function StaticArrays.Size(::Type{UnitSRange{T,F,L}})  where {T<:Union{UInt,UInt64,UInt128},F,L}
    return Size{(L < F ? 0 : Int(Base.Checked.checked_add(L - F, one(T))),)}()
end

function StaticArrays.Size(::Type{UnitSRange{T,F,L}}) where {T<:Union{Int,Int64,Int128},F,L}
    return Size{(Int(Base.Checked.checked_add(Base.Checked.checked_sub(L, F), one(T))),)}()
end

StaticArrays.Size(::Type{OneToSRange{T,L}}) where {T<:Union{Int,Int64},L} = Size{(T(L),)}()

StaticArrays.Size(::Type{OneToSRange{T,L}}) where {T,L} = Size{(Int(L - zero(T)),)}()
