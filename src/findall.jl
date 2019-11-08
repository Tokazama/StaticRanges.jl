
function Base.findall(f::Function, r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen})
    return find_all(f, r)
end

function Base.findall(f::Fix2{typeof(in)}, r::Union{OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen})
    return find_all(f, r)
end

find_all(f, x) = find_all(f, x, order(x))
find_all(f, x, xo) = findall(f, x)

find_all(f::Fix2{typeof(in)}, y, yo) = _findin(f.x, order(f.x), y, yo)

# <, <=
function find_all(f::Fix2{<:Union{typeof(<),typeof(<=)}}, r, ::ForwardOrdering)
    idx = find_last(f, r, Forward)
    return isnothing(idx) ? Int[] : firstindex(r):idx
end
function find_all(f::Fix2{<:Union{typeof(<),typeof(<=)}}, r, ::ReverseOrdering)
    idx = find_first(f, r, Reverse)
    return isnothing(idx) ? Int[] : idx:lastindex(r)
end
find_all(f::Fix2{<:Union{typeof(<),typeof(<=)}}, r, ::UnorderedOrdering) = Int[]

# >, >=
function find_all(f::Fix2{<:Union{typeof(>),typeof(>=)}}, r, ::ForwardOrdering)
    idx = find_first(f, r, Forward)
    return isnothing(idx) ? empty(r) : idx:lastindex(r)
end
function find_all(f::Fix2{<:Union{typeof(>),typeof(>=)}}, r, ::ReverseOrdering)
    idx = find_last(f, r, Reverse)
    return isnothing(idx) ? empty(r) : firstindex(r):idx
end
find_all(f::Fix2{<:Union{typeof(>),typeof(>=)}}, r, ::UnorderedOrdering) = Int[]


find_all(f::Fix2{<:Union{typeof(==),typeof(isequal)}}, r, ::UnorderedOrdering) = Int[]
function find_all(f::Fix2{<:Union{typeof(==),typeof(isequal)}}, r, ro::Ordering)
    isempty(r) && Int[]
    idx = find_first(f, r, ro)
    return isnothing(idx) ? Int[] : idx:findlast(f, r)
end

# in
#for R in (OneToRange,StaticUnitRange,AbstractLinRange,AbstractStepRange,AbstractStepRangeLen)
#    @eval begin
#        Base.findall(f::Function, r::$R) = find_all(f, r)
#    end
#end

