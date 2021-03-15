
#=


using Static
using Base: RefValue

_elcheck(::Type{T1}, ::Type{T2}) where {T1,T2<:Ref} = _elcheck(T, eltype(T2))
_elcheck(::Type{T1}, ::Type{T2}) where {T1,T2} = __elcheck(is_static(T2), T, T2)
__elcheck(::True, ::Type{T1}, ::Type{T2}) where {T1,T2} = _elcheck(T1, eltype(T2))
_elcheck(::Type{T}, ::Type{T}) where {T} = True()
_elcheck(::Type{T1}, ::Type{T2}) where {T1,T2} = False()

_check_elconvert(::Type{T1}, x::T2) where {T1,T2} = __check_elconvert(_elcheck(T1, T2), T1, x)
__check_elconvert(::True, ::Type{T}, x) where {T} = x
__check_elconvert(::False, ::Type{T}, x) where {T} = _elconvert(T, x)
_elconvert(::Type{T}, x::Ref) where {T} = Ref{T}()
_elconvert(::Type{T1}, x::T2) where {T1,T2} = __elconvert(is_static(T2), T1, x)
__elconvert(::True, ::Type{T1}, x::T2) where {T1,T2} = static(convert(T1, x))
__elconvert(::False ::Type{T1}, x::T2) where {T1,T2} = convert(T1, x)

dynamic(x::Base.RefValue) = x[]

function _unit_range_last!(start, stop::RefValue)
    stop[] = _unit_range_last!(dynamic(start), dynamic(stop))
    return stop
end
_unit_range_last!(start, stop) = Base.unitrange_last(dynamic(start), stop)


const TRef{T} = Union{T,RefValue{T}}

struct URange{T,B<:TRef{T},E<:TRef{T}} <: AbstractUnitRange{T}
    start::B  # B for begin
    stop::E   # E for end

    global _URange(start::B, stop::E) where {B,E} = new{eltype(start),B,E}(start, stop)
end

URange{Int,One,Int}(start::One, stop::Int) = _URange(start, max(0, stop))
URange{Int,One,Int}(start::One, stop::Int) = _URange(start, max(0, stop))
function URange{T,B,E}(start::B, stop::E) where {T,B,E}
    @assert known(_elcheck(T, B))
    @assert known(_elcheck(T, E))
    return _URange(start, _unit_range_last!(start, stop))
end
function URange{T}(start::B, stop::E) where {T,B,E}
    start2 = _check_elconvert(T, start2)
    return _URange(start2, _unit_range_last!(start2, _check_elconvert(T, stop)))
end
function URange(start::B, stop::E) where {B,E}
    return URange{typejoin(eltype(B),eltype(E))}(start, stop)
end

const Length{L} = URange{Int,One,L}
Length(stop::Int) = _URange(One(), max(0, stop))
Length(stop::StaticInt) = _URange(One(), max(static(0), stop))
Length(stop::Ref{Int}) = _URange(One(), max(static(0), stop))

const StaticLength{L} = Length{StaticInt{L}}
const MutableLength = Length{RefValue{Int}}
const DynamicLength = Length{Int}

can_grow_tail(::Type{URange{T,B,E}}) where {T,B,E} = ismutable(E)
can_grow_front(::Type{URange{T,B,E}}) where {T,B,E} = ismutable(B)
function ArrayInterface.can_grow_tail(::Type{T}) wehre {T<:URange}
    return can_grow_tail(T) || can_grow_front(T)
end




can_grow_tail(::Type{T}) where {T<:}

function grow_tail!()
end



# LinRange
struct LengthRange{T,R<:URange{T},L} <: AbstractRange{T}
    span::R
    length::Length{L}
end

struct DynamicStepRange{T,R<:URange{T},S} <: AbstractRange{T}
    span::R
    step::S
end



=#
