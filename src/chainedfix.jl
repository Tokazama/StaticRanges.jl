struct ChainedFix{L,F1,F2} <: Function
    link::L
    f1::F1
    f2::F2
end

function (cf::ChainedFix{L,F1,F2})(x) where {L,F1<:Function,F2<:Function}
    return cf.link(cf.f1(x), cf.f2(x))
end
(cf::ChainedFix{L,F1,F2})(x) where {L,F1<:Function,F2} = cf.link(cf.f1(x), cf.f2)
(cf::ChainedFix{L,F1,F2})(x) where {L,F1,F2<:Function} = cf.link(cf.f1, cf.f2(x))

"""
    and(x, y)

Synonymous with bitwise `&` operator but may be used to chain multiple `Fix1` or
`Fix2` operations.
"""
and(x, y) = x & y
and(x::Function, y) = ChainedFix(&, x, y)
and(x, y::Function) = ChainedFix(&, x, y)
and(x::Function, y::Function) = ChainedFix(&, x, y)

"""
    or(x, y)

Synonymous with bitwise `|` operator but may be used to chain multiple `Fix1` or
`Fix2` operations.
"""
or(x, y) = x | y
or(x::Function, y) = ChainedFix(|, x, y)
or(x, y::Function) = ChainedFix(|, x, y)
or(x::Function, y::Function) = ChainedFix(|, x, y)

const BitAnd{F1,F2} = ChainedFix{typeof(&),F1,F2}

const BitOr{F1,F2} = ChainedFix{typeof(|),F1,F2}

# TODO get this in base or remove it
Base.:&(x::Function, y) = ChainedFix(&, x, y)
Base.:&(x, y::Function) = ChainedFix(&, x, y)
Base.:&(x::Function, y::Function) = ChainedFix(&, x, y)

Base.:|(x::Function, y) = ChainedFix(|, x, y)
Base.:|(x, y::Function) = ChainedFix(|, x, y)
Base.:|(x::Function, y::Function) = ChainedFix(|, x, y)

const F2Lt{T} = Fix2{<:Union{typeof(<),typeof(<=)},T}
const F2Gt{T} = Fix2{<:Union{typeof(>),typeof(>=)},T}
const F2Eq{T} = Fix2{<:Union{typeof(isequal),typeof(==)},T}
const F2IsLess{T} = Fix2{<:Union{typeof(isless),typeof(<)},T}
