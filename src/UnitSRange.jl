struct UnitSRange{T,B,E,L} <: AbstractUnitSRange{T,B,E,L} end

@pure firstindex(::UnitSRange) = 1::Int64
@pure firstindex(::Type{<:UnitSRange}) = 1::Int64
@pure sfirstindex(::UnitSRange) = SVal{1::Int64,Int64}()
@pure sfirstindex(::Type{<:UnitSRange}) = SVal{1::Int64,Int64}()

@pure lastindex(::UnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}) where {T,B,E,L,Ti<:Integer} = L::Ti
@pure lastindex(::Type{<:UnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}}) where {T,B,E,L,Ti<:Integer} = L::Ti
@pure slastindex(::UnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}) where {T,B,E,L,Ti<:Integer} = SVal{L::Ti,Ti}()
@pure slastindex(::Type{<:UnitSRange{T,SVal{B,T},SVal{E,T},SVal{L,Ti}}}) where {T,B,E,L,Ti<:Integer} = SVal{L::Ti,Ti}()

@pure step(::UnitSRange{T,B,E,L}) where {T,B,E,L} = one(T)::T
@pure step(::Type{<:UnitSRange{T,B,E,L}}) where {T,B,E,L} = one(T)::T
@pure sstep(::UnitSRange{T,B,E,L}) where {T,B,E,L} = SOne(T)
@pure sstep(::Type{<:UnitSRange{T,B,E,L}}) where {T,B,E,L} = SOne(T)


UnitSRange{Bool}(b::SBool{B}, e::SBool{E}) where {B,E} = UnitSRange{Bool,SBool{B},SBool{E}}()
function UnitSRange{T}(b::SVal{B,T}, e::SVal{E,T}) where {B,E,T<:Integer}
    if e >= b
        return UnitSRange{T,SVal{B,T},SVal{E,T}}()
    else
        return UnitSRange{T,SVal{B,T},typeof(b-SOne(T))}()
    end
end

function UnitSRange{T}(start::SVal{B,T}, stop::SVal{E,T}) where {B,E,T}
    if stop >= start
        UnitSRange{T,SVal{B,T},SVal{T(B+floor(E-B))::T,T}}()
    else
        UnitSRange{T,SVal{B,T},SVal{T(B-oneunit(B-E)):T,T}}()
    end
end

UnitSRange{T,SVal{B,T},SVal{E,T}}() where {T<:Union{Int,Int64,Int128},B,E} =
    UnitSRange{T,SVal{B,T},SVal{E,T},SVal{Int(checked_add(checked_sub(E, B), one(T))),Int}}()
UnitSRange{T,SVal{B,T},SVal{E,T}}() where {T<:Union{UInt,UInt64,UInt128},B,E} =
    UnitSRange{T,SVal{B,T},SVal{E,T},typeof(E < B ? SZero(T) : (E - B) + SOne(T))}()
UnitSRange{T,SVal{B,T},SVal{E,T}}() where {T<:Real,B,E} =
    UnitSRange{T,SVal{B,T},SVal{E,T},typeof(SVal{Integer(E::T - B::T + oneunit(T))}())}()

