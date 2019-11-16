values_type(::T) where {T} = values_type(T)
values_type(::Type{T}) where {T} = T

keys_type(::T) where {T<:AbstractVector} = LinearIndices{1,Tuple{Base.OneTo{Int64}}}
keys_type(x::T) where {T} = typeof(keys(x))

## TODO these should go in base if possible
struct BitAnd{F1<:Function,F2<:Function} <: Function
    f1::F1
    f2::F2
end

(f::BitAnd)(x) = f.f1(x) & f.f2(x)

Base.:&(f1::Function, f2::Function) = BitAnd(f1, f2)

struct BitOr{F1<:Function,F2<:Function} <: Function
    f1::F1
    f2::F2
end

(f::BitOr)(x) = f.f1(x) | f.f2(x)

Base.:|(f1::Function, f2::Function) = BitOr(f1, f2)

F2Lt{T} = Fix2{<:Union{typeof(<),typeof(<=)},T}
F2Gt{T} = Fix2{<:Union{typeof(>),typeof(>=)},T}
F2Eq{T} = Fix2{<:Union{typeof(isequal),typeof(==)},T}