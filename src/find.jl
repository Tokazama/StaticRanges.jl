
# Ideally the previous _find_all_in method could be used, but things like `div(::Second, ::Integer)`
# don't work. So this helps drop units by didingin by oneunit(::T) of the same type.
unsafe_find_value(val, r::R) where {R}= _add1(_int(static_div(val - static_first(r), static_step(r))))

unsafe_find_value(x, r::MutableRange) = unsafe_find_value(x, parent(r))
unsafe_find_value(x, r::StaticRange) = unsafe_find_value(x, parent(r))
unsafe_find_value(x, r::LinRange) = _add1(_int((x - r.start) / (r.stop - r.start) * r.lendiv))
unsafe_find_value(x, r::StepRangeLen) = _int(((x - r.ref) / step_hp(r)) + r.offset)
unsafe_find_value(x, r::UnitRange) = _add1(_int(x - first(r)))
unsafe_find_value(x, r::StepRange) = _add1(_int((x - first(r)) / step(r)))
unsafe_find_value(x, r::OneTo) = _int(x)
unsafe_find_value(x, r::DynamicAxis) = _int(x)


# only really applies to ordered vectors
_find_all(::Type{T},        fi,        li) where {T} = fi:li
_find_all(::Type{T}, ::Nothing,        li) where {T} = _empty_ur(T)
_find_all(::Type{T},        fi, ::Nothing) where {T} = _empty_ur(T)
_find_all(::Type{T}, ::Nothing, ::Nothing) where {T} = _empty_ur(T)

###
### find_first
###

"""
    find_first(predicate::Function, A)

Return the index or key of the first element of A for which predicate returns
true. Return nothing if there is no such element.

Indices or keys are of the same type as those returned by keys(A) and pairs(A).

# Examples

```jldoctest
julia> using StaticRanges

julia> A = [1, 4, 2, 2];

julia> find_first(iseven, A)
2

julia> find_first(x -> x>10, A) # returns nothing, but not printed in the REPL

julia> find_first(isequal(4), A)
2

julia> find_first(iseven, [1 4; 2 2])
CartesianIndex(2, 1)
```
"""
find_first(f, collection) = _find_first(static_isempty(collection), f, collection)
_find_first(::True, f, collection) = nothing
_find_first(::False, f, collection) = unsafe_find_first(f, collection)
function _find_first(b::Bool, f, collection)
    if b
        return nothing
    else
        return dynamic(unsafe_find_first(f, collection))
    end
end
@inline function unsafe_find_first(f, x)
    for (i, x_i) in pairs(x)
        f(x_i) && return i
    end
    return nothing
end


# <
function _unsafe_find_first_lt_forward(val, r::AbstractRange)
    return ifelseop(ge(static_first(r), val), return_nothing, return_static_one, r)
end
function _unsafe_find_first_lt_reverse(val, r::AbstractRange)
    index = unsafe_find_value(val, r)
    len = static_length(r)
    return ifelseop(le(len, index),
        return_nothing,
        __unsafe_find_first_lt_reverse,
        val, index, r
    )
end
function __unsafe_find_first_lt_reverse(val, index, r::AbstractRange)
    return ifelseop(gt(static(1), index),
        return_static_one,
        ___unsafe_find_first_lt_reverse,
        val, index, r
    )
end
___unsafe_find_first_lt_reverse(val, index, r) = ifadd1(@inbounds(r[index]) >= val, index)
@inline function unsafe_find_first(f::Fix2{typeof(<)}, r::AbstractRange)
    start = static_first(r)
    s = static_step(r)
    return ifelseop(gt(s, zero(s)),
        _unsafe_find_first_lt_forward,
        _unsafe_find_first_lt_reverse,
        f.x, r
    )
end

# <=
@inline function unsafe_find_first(f::Fix2{typeof(<=)}, r::AbstractRange)
    s = static_step(r)
    return ifelseop(gt(s, zero(s)),
        _find_first_le_forward,
        _find_first_le_reverse,
        f.x, r
    )
end
function _find_first_le_forward(val, r::AbstractRange)
    return ifelseop(gt(static_first(r), val), return_nothing, return_static_one, val)
end
function _find_first_le_reverse(val, r::AbstractRange)
    return ifelseop(le(static_first(r), val), return_static_one, __find_first_le_reverse, val, r)
end
function __find_first_le_reverse(val, r::AbstractRange)
    return ifelseop(gt(static_last(r), val), return_nothing, ___find_first_le_reverse, val, r)
end
function ___find_first_le_reverse(val, r::AbstractRange)
    index = unsafe_find_value(val, r)
    if @inbounds(r[index]) > val
        return _add1(index)
    else
        return index
    end
end

# >
@inline function unsafe_find_first(f::Fix2{typeof(>)}, r::AbstractRange)
    s = static_step(r)
    return ifelseop(gt(s, zero(s)), _find_first_gt_forward, _find_first_gt_reverse, f.x, r)
end
function _find_first_gt_forward(val, r::AbstractRange)
    return ifelseop(le(static_last(r), val),
        return_nothing,
        __find_first_gt_forward,
        val, r
    )
end
function __find_first_gt_forward(val, r::AbstractRange)
    return ifelseop(gt(static_first(r), val),
        return_static_one,
        ___find_first_gt_forward,
        val, r
    )
end
function ___find_first_gt_forward(val, r::AbstractRange)
    index = unsafe_find_value(val, r)
    if @inbounds(r[index]) <= val
        return _add1(index)
    else
        return index
    end
end

function _find_first_gt_reverse(val, r::AbstractRange)
    return ifelseop(gt(static_first(r), val),
        return_static_one,
        __find_first_gt_reverse,
        val, r
    )
end
function __find_first_gt_reverse(val, r)
    return ifelseop(lt(static_last(r), val),
        return_nothing,
        unsafe_find_value,
        val, r
    )
end


# >=
@inline function unsafe_find_first(f::Fix2{typeof(>=)}, r::AbstractRange)
    s = static_step(r)
    return ifelseop(gt(s, zero(s)),
        _find_first_ge_forward,
        _find_first_ge_reverse,
        f.x, r
    )
end
function _find_first_ge_forward(val, r::AbstractRange)
    return ifelseop(lt(static_last(r), val),
        return_nothing,
        __find_first_ge_forward,
        val, r
    )
end
function __find_first_ge_forward(val, r::AbstractRange)
    return ifelseop(ge(static_first(r), val),
        return_static_one,
        ___find_first_ge_forward,
        val, r
    )
end
function ___find_first_ge_forward(val, r::AbstractRange)
    index = unsafe_find_value(val, r)
    if @inbounds(r[index]) < val
        return _add1(index)
    else
        return index
    end
end
function _find_first_ge_reverse(val, r::AbstractRange)
    return ifelseop(ge(static_first(r), val),
        return_static_one,
        return_nothing,
        r
    )
end

# ==
function unsafe_find_first(f::Equal, collection::AbstractRange)
    x = f.x
    if minimum(collection) > x || maximum(collection) < x
        return nothing
    else
        index = unsafe_find_value(x, collection)
        if @inbounds(collection[index]) == x
            return index
        else
            return nothing
        end
    end
end

###
### find_last
###
"""
    find_last(predicate::Function, A)

Return the index or key of the last element of A for which predicate returns
true. Return nothing if there is no such element.

Indices or keys are of the same type as those returned by keys(A) and pairs(A).

# Examples

```jldoctest
julia> using StaticRanges

julia> find_last(iseven, [1, 4, 2, 2])
4

julia> find_last(x -> x>10, [1, 4, 2, 2]) # returns nothing, but not printed in the REPL

julia> find_last(isequal(4), [1, 4, 2, 2])
2

julia> find_last(iseven, [1 4; 2 2])
CartesianIndex(2, 2)
```
"""
find_last(f, collection) = _find_last(static_isempty(collection), f, collection)
_find_last(::True, f, collection) = nothing
_find_last(::False, f, collection) = unsafe_find_last(f, collection)
function _find_last(b::Bool, f, collection)
    if b
        return nothing
    else
        return dynamic(unsafe_find_last(f, collection))
    end
end

@inline unsafe_find_last(f::Equal, x) = unsafe_find_lasteq(f.x,   x)
@inline function unsafe_find_last(f, collection)
    for (i, collection_i) in Iterators.reverse(pairs(collection))
        f(collection_i) && return i
    end
    return nothing
end

# >
@inline function unsafe_find_last(f::Fix2{typeof(>)}, r::AbstractRange)
    s = static_step(r)
    return ifelseop(gt(s, zero(s)),
        _find_last_gt_forward,
        _find_last_gt_reverse,
        f.x, r
    )
end
function _find_last_gt_forward(val, r::AbstractRange)
    return ifelseop(le(static_last(r), val),
        return_nothing,
        static_length,
        r
    )
end

function _find_last_gt_reverse(val, r::AbstractRange)
    return ifelseop(le(static_first(r), val),
        return_nothing,
        __find_last_gt_reverse,
        val, r
    )
end
function __find_last_gt_reverse(val, r::AbstractRange)
    ifelseop(gt(static_last(r), val),
        _static_length,
        ___find_last_gt_reverse,
        val, r
    )
end
function ___find_last_gt_reverse(val, r::AbstractRange)
    index = unsafe_find_value(val, r)
    if (@inbounds(r[index]) == val) & (index != 1)
        return _sub1(index)
    else
        return index
    end
end

# >=
@inline function unsafe_find_last(f::Fix2{typeof(>=)}, r::AbstractRange)
    s = static_step(r)
    return ifelseop(gt(s, zero(s)),
        _find_last_ge_forward,
        _find_last_ge_reverse,
        f.x, r
    )
end
function _find_last_ge_forward(val, r::AbstractRange)
    return ifelseop(lt(static_last(r), val),
        return_nothing,
        static_length,
        r
    )
end
function _find_last_ge_reverse(val, r::AbstractRange)
    index = unsafe_find_value(val, r)
    return ifelseop(gt(static(1), index),
        return_nothing,
        __find_last_ge_reverse,
        val, index, r
    )
end
function __find_last_ge_reverse(val, index, r::AbstractRange)
    ifelseop(gt(static_last(r), val),
        _static_length,
        ___find_last_ge_reverse,
        val, index, r
    )
end
function ___find_last_ge_reverse(val, index, r::AbstractRange)
    if @inbounds(r[index]) < val
        return _sub1(index)
    else
        return index
    end
end


# <
#=@inline function unsafe_find_last(f::Fix2{typeof(<)}, r::AbstractRange)
    x = f.x
    if step(r) > 0
        index = unsafe_find_value(x, r)
        if 1 > index
            return nothing
        else
            if lastindex(r) < index
                return lastindex(r)
            else
                if @inbounds(r[index]) < x
                    return index
                else
                    return ifelseop(ne(index, static(1)), _sub1, return_nothing, index)
                end
            end
        end
    else
        if last(r) >= x
            return nothing
        else
            return lastindex(r)
        end
    end
end=#

@inline function unsafe_find_last(f::Fix2{typeof(<)}, r::AbstractRange)
    s = static_step(r)
    return ifelseop(gt(s, zero(s)),
        _find_last_lt_forward,
        _find_last_lt_reverse,
        f.x, r
    )
end
function _find_last_lt_forward(val, r::AbstractRange)
    index = unsafe_find_value(val, r)
    ifelseop(gt(static(1), index), return_nothing, __find_last_lt_forward, val, index, r)
end
function __find_last_lt_forward(val, index, r::AbstractRange)
    len = static_length(r)
    return ifelseop(lt(len, index), first, ___find_last_lt_forward, (len, val, index, r))
end
___find_last_lt_forward(x::Tuple) = ___find_last_lt_forward(x...)
function ___find_last_lt_forward(len, val, index, r::AbstractRange)
    if @inbounds(r[index]) < val
        return index
    elseif index != 1
        return _sub1(index)
    else
        return nothing
    end
end
function _find_last_lt_reverse(val, r::AbstractRange)
    return ifelseop(lt(static_last(r), val),
        static_length,
        return_nothing,
        r
    )
end

# <=
@inline function unsafe_find_last(f::Fix2{typeof(<=)}, r::AbstractRange)
    s = static_step(r)
    return ifelseop(gt(s, zero(s)),
        _find_last_le_forward,
        _find_last_le_reverse,
        f.x, r
    )
end
function _find_last_le_forward(val, r::AbstractRange)
    return ifelseop(gt(static_first(r), val),
        return_nothing,
        __find_last_le_forward,
        val, r
    )
end
function __find_last_le_forward(val, r::AbstractRange)
    return ifelseop(
        le(static_last(r), val),
        _static_length,
        ___find_last_le_forward,
        val, r
    )
end
function ___find_last_le_forward(val, r::AbstractRange)
    index = unsafe_find_value(val, r)
    if @inbounds(r[index]) <=  val
        return index
    elseif index != 1
        return _sub1(index)
    else
        return nothing
    end
end
function _find_last_le_reverse(val, r::AbstractRange)
    return ifelseop(gt(static_last(r), val),
        return_nothing,
        static_length,
        r
    )
end

# ==
function unsafe_find_lasteq(x, collection)
    for (i, collection_i) in Iterators.reverse(pairs(collection))
        x == collection_i && return i
    end
    return nothing
end
unsafe_find_last(f::Equal, collection::AbstractRange) = unsafe_find_first(f, collection)

###
### find_all
###
find_all(f, x) = collect(k for (k,v) in pairs(x) if f(v))
find_all(f::Fix2{typeof(in)}, x) = find_all_in(f.x, x)
@inline find_all(f::Or, x::AbstractRange) = combine(find_all(f.f1, x), find_all(f.f2, x))
@inline find_all(f::And, x::AbstractRange) = intersect(find_all(f.f1, x), find_all(f.f2, x))

@inline function find_all(f::Fix2{typeof(<)}, r::AbstractRange{T}) where {T}
    x = f.x
    if step(r) > zero(T)
        return _find_all(keytype(r), firstindex(r), find_last(<(x), r))
    elseif step(r) < zero(T)
        return _find_all(keytype(r), find_first(<(x), r), lastindex(r))
    else
        return _find_all(keytype(r), nothing, nothing)
    end
end

@inline function find_all(f::Fix2{typeof(<=)}, r::AbstractRange{T}) where {T}
    x = f.x
    if step(r) > zero(T)
        return _find_all(keytype(r), firstindex(r), find_last(<=(x), r))
    elseif step(r) < zero(T)
        return _find_all(keytype(r), find_first(<=(x), r), lastindex(r))
    else
        return _find_all(keytype(r), nothing, nothing)
    end
end

@inline function find_all(f::Fix2{typeof(>)}, r::AbstractRange{T}) where {T}
    x = f.x
    if step(r) > zero(T)
        return _find_all(keytype(r), find_first(>(x), r), lastindex(r))
    elseif step(r) < zero(T)
        return _find_all(keytype(r), firstindex(r), find_last(>(x), r))
    else
        return _empty_ur(keytype(r))
    end
end

@inline function find_all(f::Fix2{typeof(>=)}, r::AbstractRange{T}) where {T}
    x = f.x
    if step(r) > zero(T)
        return _find_all(keytype(r), find_first(>=(x), r), lastindex(r))
    elseif step(r) < zero(T)
        return _find_all(keytype(r), firstindex(r), find_last(>=(x), r))
    else
        return _empty_ur(keytype(r))
    end
end

@inline function find_all(f::Equal, r::AbstractRange{T}) where {T}
    if (step(r) > zero(T)) | (step(r) < zero(T))
        return _find_all(keytype(r), find_first(f, r), find_last(f, r))
    else
        return _empty_ur(keytype(r))
    end
end

@inline function find_all(f::NotIn, r::AbstractRange{T}) where {T}
    x = f.x
    if (step(r) > zero(T)) | (step(r) < zero(T))
        return combine(find_all(>(x), r), find_all(<(x), r))
    else
        return GapRange(UnitRange(1, 0), UnitRange(1, 0))
    end
end

###
### find_all_in
###

# find x in y

# find all values of x in y
@inline function find_all_in(x::Interval{:closed,:closed,T}, y) where {T}
    return intersect(find_all(>=(x.left), y), find_all(<=(x.right), y))
end

@inline function find_all_in(x::Interval{:closed,:open,T}, y) where {T}
    return intersect(find_all(>=(x.left), y), find_all(<(x.right), y))
end
@inline function find_all_in(x::Interval{:open,:closed,T}, y) where {T}
    return intersect(find_all(>(x.left), y), find_all(<=(x.right), y))
end
@inline function find_all_in(x::Interval{:open,:open,T}, y) where {T}
    return intersect(find_all(>(x.left), y), find_all(<(x.right), y))
end

@inline function find_all_in(x::AbstractRange{Tx}, y::AbstractRange{Ty}) where {Tx,Ty}
    if isempty(x)
        return _empty(x, y)
    elseif isempty(y)
        return _empty(x, y)
    elseif known_step(x) === known_step(y) !== nothing
        return _find_all_in_same_step(x, y)
    else
        return _find_all_in(x, y)
    end
end

function find_all_in(a, b)
    ind  = Vector{eltype(keys(a))}()
    bset = Set(b)
    @inbounds for (i,ai) in pairs(a)
        ai in bset && push!(ind, i)
    end
    return ind
end
#=

    r = @inferred(find_all(in(UnitRange(1,10)), static(UnitRange(1,8))))
    @test r == 1:8
    @test isa(r, UnitRange)

    r = @inferred(find_all(in(Base.OneTo(10)), StaticRanges.mutable(UnitRange(1, 8))))
    @test r == OneTo(8)
    @test isa(r, UnitRange) == true

    r = @inferred(find_all(in(static(UnitRange(1, 8))), static(UnitRange(1, 10))))
    @test r == static(UnitRange(1, 8))

    @test find_all(in(collect(1:10)), 1:20) == find_all(in(1:10), 1:20)
    @test find_all(in(1:10), collect(1:20)) == 1:10

    @testset "steps match but no overlap" begin
        r = @inferred(find_all_in(1:3, 4:5))
        @test r == 1:0
        @test isa(r, UnitRange)
    end

=#

# if steps are not integers then we need to make sure that something like
# startx = 1 and starty = 1.1 doesn't make the whole thing offset from eachother
@inline function _find_all_in_same_step(x::AbstractRange, y::AbstractRange)
    fx = _drop_unit(static_first(x))
    fy = _drop_unit(static_first(y))
    lx = _drop_unit(static_last(x))
    ly = _drop_unit(static_last(y))
    xydiff = fx - fy
    if !iszero(static_rem(xydiff, static(1)))
        return one(xydiff):zero(xydiff)
    elseif static_step(x) > 0
        return _int((max(fx, fy) - fy) + static(1)):_int((min(lx, ly) - fy) + static(1))
    else
        return _int((min(fx, fy) - fy) + static(1)):_int((max(lx, ly) - fy) + static(1))
    end
end
@inline function _find_all_in_same_step(x::AbstractRange{<:Integer}, y::AbstractRange{<:Integer})
    fx = _drop_unit(static_first(x))
    fy = _drop_unit(static_first(y))
    lx = _drop_unit(static_last(x))
    ly = _drop_unit(static_last(y))
    if _drop_unit(static_step(x)) > 0
        return _int(max(fx, fy) - fy + static(1)):_int(min(lx, ly) - fy + static(1))
    else
        return _int(min(fx, fy) - fy + static(1)):_int(max(lx, ly) - fy + static(1))
    end
end

#=
function _findin(r::AbstractRange{<:Integer}, span::AbstractUnitRange{<:Integer})
    local ifirst
    local ilast
    fspan = first(span)
    lspan = last(span)
    fr = first(r)
    lr = last(r)
    sr = step(r)
    if sr > 0
        ifirst = fr >= fspan ? 1 : ceil(Integer,(fspan-fr)/sr)+1
        ilast = lr <= lspan ? length(r) : length(r) - ceil(Integer,(lr-lspan)/sr)
    elseif sr < 0
        ifirst = fr <= lspan ? 1 : ceil(Integer,(lspan-fr)/sr)+1
        ilast = lr >= fspan ? length(r) : length(r) - ceil(Integer,(lr-fspan)/sr)
    else
        ifirst = fr >= fspan ? 1 : length(r)+1
        ilast = fr <= lspan ? length(r) : 0
    end
    r isa AbstractUnitRange ? (ifirst:ilast) : (ifirst:1:ilast)
end
=#
###
### manage steps
###
function _to_step(s::S, x::SX, y::SY) where {S,SX,SY}
    return __to_step(eq(gt(y, zero(y)), gt(x, zero(x))), s)
end
__to_step(::True, s::S) where {S} = _int(s)
__to_step(::False, s::S) where {S} = _int(_flip_int(s))
function __to_step(flip::Bool, s::S) where {S}
    if flip
        return dynamic(s)
    else
        return dynamic(-s)
    end
end
_flip_int(x::Int) = -x
_flip_int(x::StaticInt) = -x
_flip_int(x::StaticFloat64{X}) where {X} = static(_flip_int(X))
_flip_int(x) = -x


###
### steps are not exactly the same
###
@inline function _find_all_in(x::AbstractRange, y::AbstractRange)
    sx = _drop_unit(static_step(x))
    sy = _drop_unit(static_step(y))
    sxy = _drop_unit(static_div(sx, sy))
    startx = _drop_unit(static_first(x))
    starty = _drop_unit(static_first(y))
    stopx = _drop_unit(static_last(x))
    stopy = _drop_unit(static_last(y))

    if iszero(sxy)
        sxy2 = div(sy, sx)
        if !iszero(rem(startx - starty, div(sxy2, sx)))
            return _empty(x, y)
        else
            suby = intersect(x, y)
            f = _int(unsafe_find_first(==(static_first(suby)), y))
            l = _int(unsafe_find_first(==(static_last(suby)), y))
            return f:_to_step(static(1), sx, sy):l
        end
    else
        if !iszero(rem(startx - starty, div(sxy, sx)))
            return _empty(x, y)
        else
            suby = intersect(x, y)
            f = _int(unsafe_find_first(==(static_first(suby)), y))
            l = _int(unsafe_find_first(==(static_last(suby)), y))
            return f:_to_step(sxy, sx, sy):l
        end
    end

    #=
    if iszero(sxy)
        sxy2 = div(sy, sx)
        if !iszero(rem(startx - starty, div(sxy2, sx)))
            return _empty(x, y)
        else
            suby = intersect(x, y)
            f = _int(unsafe_find_first(==(static_first(suby)), y))
            l = _int(unsafe_find_first(==(static_last(suby)), y))
            return f:_to_step(static(1), sx, sy):l
        end
    else
        if !iszero(rem(startx - starty, div(sxy, sx)))
            return _empty(x, y)
        else
            suby = intersect(x, y)
            f = _int(unsafe_find_first(==(static_first(suby)), y))
            l = _int(unsafe_find_first(==(static_last(suby)), y))
            return f:_to_step(sxy, sx, sy):l
        end
    end
    =#
end

#=
@inline function _find_all_in(x, y)
    fx = _drop_unit(static_first(x))
    fy = _drop_unit(static_first(y))
    sx = _drop_unit(static_step(x))
    sy = _drop_unit(static_step(y))
    lx = _drop_unit(static_last(x))
    ly = _drop_unit(static_last(y))

    if sx > 0
        if sy > 0
            f = max(fx, fy)
            l = min(lx, ly)
        else
            f = min(lx, fy)
            l = max(fx, ly)
        end
    else
        if sy > 0
            f = max(lx, fy)
            l = min(fx, ly)
        else
            f = min(fx, fy)
            l = max(lx, ly)
        end
    end
end
=#

#=

f1 = 1:2:11
f2 = 3:2:9
f3 = 3:4:15

r1 = 11:-2:1
r2 = 9:-2:2
r3 = 15:-4:3

find_all(in(f1), f1) == 1:length(f1)
find_all(in(f2), f1) == 2:5
find_all(in(f2), f1) == 2:2:6

find_all(in(f1), r1) == length(f1):-1:1
find_all(in(f2), r1) == 5:-1:2
find_all(in(f2), r1) == 6:-2:2

=#

combine(x::OneToUnion, y::OneToUnion) = promote_type(typeof(x), typeof(y))(max(x, y))

###
### AbstractUnitRange
###
function combine(x::AbstractUnitRange{<:Integer}, y::AbstractUnitRange{<:Integer})
    R = promote_type(typeof(x), typeof(y))
    if isempty(x)
        if isempty(y)
            return GapRange(R(1, 0), R(1, 0))
        else
            return GapRange(R(1, 0), R(first(y), last(y)))
        end
    elseif isempty(y)
        return GapRange(R(1, 0), R(first(x), last(x)))
    else
        xmax = last(x)
        xmin = first(x)
        ymax = last(y)
        ymin = first(y)
        if xmax < ymin  # all x below y
            return GapRange(R(xmin, xmax), R(ymin, ymax))
        elseif ymax < xmin  # all y below x
            return GapRange(R(ymin, ymax), R(xmin, xmax))
        else # x and y overlap so we just set the first range to length of one
            rmin = min(xmin, ymin)
            return GapRange(R(rmin, rmin), R(rmin + oneunit(eltype(R)), max(xmax, ymax)))
        end
    end
end

