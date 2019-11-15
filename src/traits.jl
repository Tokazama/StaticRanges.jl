StaticArrays.Size(::Type{LinSRange{T,B,E,L,D}}) where {T,B,E,L,D} = Size{(L,)}()

StaticArrays.Size(::Type{StepSRangeLen{T,Tr,Ts,R,S,L,F}}) where {T,Tr,Ts,R,S,L,F} = Size{(L,)}()

function StaticArrays.Size(::Type{StepSRange{T,Ts,F,S,L}})  where {T,Ts,F,S,L}
    return Size{(start_step_stop_to_length(T, F, S, L),)}()
end

function StaticArrays.Size(::Type{UnitSRange{T,F,L}})  where {T<:Union{UInt,UInt64,UInt128},F,L}
    return Size{(L < F ? zero(T) : Base.Checked.checked_add(L - F, one(T)),)}()
end

function StaticArrays.Size(::Type{UnitSRange{T,F,L}}) where {T<:Union{Int,Int64,Int128},F,L}
    return Size{(Base.Checked.checked_add(Base.Checked.checked_sub(L, F), one(T)),)}()
end

StaticArrays.Size(::Type{OneToSRange{T,L}}) where {T<:Union{Int,Int64},L} = Size{(T(L),)}()

StaticArrays.Size(::Type{OneToSRange{T,L}}) where {T,L} = Size{(Integer(L - zero(T)),)}()

StaticArrays.Size(::Type{T}) where {T<:MRange} = Size{(Dynamic(),)}()


# TODO would be better to have this implemented in StaticArrays
_Size(::Type{T}) where {T<:Tuple} = Size{StaticArrays.get.(Tuple(Length.(T.parameters)))}()

Base.checkindex(::Type{Bool}, r::SRange, i) = _checkindex(Length(r), i)
_checkindex(::Length{L}, i::Integer) where {L} = (i < 1 || i > L) ? false : true
function _checkindex(::Length{L}, i::AbstractVector{<:Integer}) where {L}
    return minimum(i) < 1 || maximum(i) > L ? false : true
end
