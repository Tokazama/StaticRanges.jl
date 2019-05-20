"""
    UnitSRange{T,B,E,L}

# Examples

```jldoctest
```
"""
struct UnitSRange{T,B,E,L} <: StaticUnitRange{T,B,E,L} end

UnitSRange{Bool}(start::SBool{B}, stop::SBool{E}) where {B,E} = UnitSRange{Bool,SBool{B},SBool{E}}(start, stop)

function UnitSRange{T}(start::B, stop::E) where {B<:SReal,E<:SReal,T<:BaseInteger}
    if stop >= start
        return UnitSRange{T,B}(start, stop)
    else
        return UnitSRange{T,B}(start, convert_static_val(T, start-sone(T)))
    end
end

function UnitSRange{T}(start::B, stop::E) where {B<:SReal,E<:SReal,T}
    if stop >= start
        UnitSRange{T,B}(start, convert_static_val(T, start+floor(stop-start)))
    else
        UnitSRange{T,B}(start, convert_static_val(T, start-sone(start - stop)))
    end
end

UnitSRange{T,B}(start::B, stop::E) where {T<:Union{Int,Int64,Int128},B,E} =
    UnitSRange{T,B,E}(start, stop, int((stop - start) + sone(T)))

UnitSRange{T,B}(start::B, stop::E) where {T<:Union{UInt,UInt64,UInt128},B,E} =
    UnitSRange{T,B,E}(start, stop, stop < stop ? SZero(T) : (stop - start) + sone(T))

UnitSRange{T,B}(start::B, stop::E) where {T<:Real,B,E} =
    UnitSRange{T,B,E}(start, stop, integer(start - stop + oneunit(T)))

UnitSRange{T,B,E}(start::B, stop::E, len::L) where {T,B,E,L} = UnitSRange{T,B,E,L}()


"""
    UnitMRange

"""
mutable struct UnitMRange{T,B,E} <: StaticUnitRange{T,B,E,Dynamic}
    start::B
    stop::E

     UnitMRange{Bool}(start::Bool, stop::SBool{E}) where E =
        new{Bool,Bool,SBool{E}}(start, stop)

     UnitMRange{T}(start::SInteger{B}, stop::T) where {T<:BaseInteger,B} =
        new{T,SInteger{B,T},T}(B::T, ifelse(stop >= B::T, stop, convert(T, B::T - oneunit(stop - B::T))))

     UnitMRange{T}(start::T, stop::SInteger{E}) where {T<:BaseInteger,E} =
        new{T,T,SInteger{E}}(start, SInteger{ifelse(E::T >= start, stop, convert(T,start-oneunit(E::T - start)))}())

     function UnitMRange{T}(start::SReal{B}, stop::T) where {T,B}
         if stop >= B::T
             new{T,typeof(start),T}(start, convert(T, B::T + floor(stop - B::T)))
         else
             new{T,typeof(start),T}(start, convert(T, oneunit(stop - B::T)))
         end
     end

     function UnitMRange{T}(start::T, stop::SReal{E}) where {T,E}
         if stop >= start
             last = convert_static_val(T, start + floor(E::T - start))
         else
             last = convert_static_val(T, start - floor(E::T - start))
         end
         new{T,T,typeof(last)}(start, last)
     end
end

Base.show(io::IO, r::StaticUnitRange) = print(io, "$(first(r)):$(last(r)) \t (static)")

#=
# srange --> UnitSRange
_sr(b::Val{B}, ::Nothing, ::Nothing, l::SVal{L}) where {B,L} = ()
_sr(b::Val{B}, ::Nothing, e::Val{E},  ::Nothing) where {B,E} = ()

# srange --> UnitMRange
_sr(b::Real, ::Nothing, ::Nothing, l::SVal{L}) where {L} = ()
_sr(b::Val{B}, ::Nothing, ::Nothing, l::Integer) where {B} = ()

_sr(b::Real, ::Nothing, e::Val{E},  ::Nothing) where {E} = ()
_sr(b::Val{B}, ::Nothing, e::Real,  ::Nothing) where {B} = ()
=#

# entry point for srange
StaticUnitRange(start::SVal, stop::SVal) = UnitSRange(start, stop)
StaticUnitRange(start::SVal, stop::Any) = UnitMRange(start, stop)
StaticUnitRange(start::Any, stop::SVal) = UnitMRange(start, stop)
