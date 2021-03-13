
###
### grow_beg!
###
# can't call grow_beg! on this
# function grow_beg!(x::DynamicAxis{T}, n::Unsigned) where {T} end

function grow_beg!(x, n::Integer)
    n < 0 && throw(ArgumentError("new length must be ≥ 0"))
    return unsafe_grow_beg!(x, n)
end
unsafe_grow_beg!(x::Vector, n) = Base._growbeg!(x, n)
unsafe_grow_beg!(x::MutableRange, n) = setfield!(x, :parent, unsafe_grow_beg(parent(x), n))

###
### grow_end!
###
""" grow_end! """
function grow_end!(x, n::Integer)
    n < 0 && throw(ArgumentError("new length must be ≥ 0"))
    unsafe_grow_end!(x, n)
    return x
end
unsafe_grow_end!(x::Vector, n) = Base._growend!(x, n)
unsafe_grow_end!(x::MutableRange, n) = setfield!(x, :parent, unsafe_grow_end(parent(x), n))

""" grow_end """
function grow_end(x, n::Integer)
    n < 0 && throw(ArgumentError("n must be positive; got $n"))
    return unsafe_grow_end(x, n)
end
function unsafe_grow_end(x::AbstractRange, n::Integer)
    if known_step(x) === 0
        s = step(x)
        return first(x):s:(last(x) + (s * n))
    else
        return first(x):(last(x) + n)
    end
end

###
### grow_to!
###
function grow_to!(x, n::Integer)
    len = length(x)
    if len < n
        unsafe_grow_to!(x, n)
        return x
    elseif len == n
        return x
    else
        throw(ArgumentError("new length must be ≥ than length of collection, got length $(length(x))."))
    end
end

unsafe_grow_to!(x::AbstractRange, n::Integer) = unsafe_grow_end!(x, n - length(x))

function grow_to(x, n::Integer)
    len = length(x)
    if len <= n
        return unsafe_grow_to(x, n)
    else
        throw(ArgumentError("new length must be ≥ than length of collection, got length $(length(x))."))
    end
end
unsafe_grow_to(x::AbstractRange, n::Integer) = unsafe_grow_end(x, n - length(x))

###
### shrink_beg!
###
function shrink_beg!(x, n::Integer)
    n > length(x) && throw(ArgumentError("new length cannot be < 0"))
    return unsafe_shrink_beg!(x, n)
end
unsafe_shrink_beg!(x::Vector, n) = Base._deletebeg!(x, n)
unsafe_shrink_beg!(x::MutableRange, n) = setfield!(x, :parent, unsafe_shrink_beg(parent(x), n))

###
### shrink_end!
###
function shrink_end!(x, n::Integer)
    n < 0 && throw(ArgumentError("new length must be ≥ 0"))
    return unsafe_shrink_end!(x, n)
end
unsafe_shrink_end!(x::Vector, n) = Base._deleteend!(x, n)
unsafe_shrink_end!(x::MutableRange, n) = setfield!(x, :parent, unsafe_shrink_end(parent(x), n))

###
### shrink_to!(x::AbstractRange, n::Integer
###
function shrink_to!(x, n::Integer)
    len = length(x)
    if len > n
        return unsafe_shrink_to!(x, n)
    elseif len == n
        return x
    else
        throw(ArgumentError("new length must be ≤ than length of collection, got length $(length(x))."))
    end
end

unsafe_shrink_to!(x, n) = unsafe_shrink_end!(x, length(x) - n)

function grow_beg(x, n::Integer)
    n < 0 && throw(ArgumentError("n must be positive; got $n"))
    return unsafe_grow_beg(x, n)
end
function unsafe_grow_beg(x::AbstractRange, n::Integer)
    if known_step(x) === 0
        s = step(x)
        return (first(x) - (s * n)):s:last(x)
    else
        return (first(x) - n):last(x)
    end
end
function shrink_beg(x, n::Integer)
    n < 0 && throw(ArgumentError("n must be positive; got $n"))
    return unsafe_shrink_beg(x, n)
end
function unsafe_shrink_beg(x::AbstractRange, n::Integer)
    if known_step(x) === 0
        s = step(x)
        return (first(x) + (s * n)):s:last(x)
    else
        return (first(x) + n):last(x)
    end
end

function shrink_end(x, n::Integer)
    n < 0 && throw(ArgumentError("n must be positive; got $n"))
    return unsafe_shrink_end(x, n)
end

function unsafe_shrink_end(x::AbstractRange, n::Integer)
    if known_step(x) === 0
        s = step(x)
        return first(x):s:(last(x) - (s * n))
    else
        return first(x):(last(x) - n)
    end
end

