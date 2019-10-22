Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::OneToRange) = r
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::AbstractStepRange) = r
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::AbstractStepRangeLen) = r
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::AbstractLinRange) = r


function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::StepSRange)
    if isstatic(x)
        return srange(-first(r), step=-step(r), length=length(r))
    else
        return mrange(-first(r), step=-step(r), length=length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::StepMRange)
    return mrange(-first(r), step=-step(r), length=length(r))
end


function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::StepSRangeLen)
    if isstatic(r)
        return StepMRangeLen(-r.ref, -r.step, length(r), r.offset)
    else
        return StepMRangeLen(-r.ref, -r.step, length(r), r.offset)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::StepMRangeLen)
    return StepMRangeLen(-r.ref, -r.step, length(r), r.offset)
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::LinSRange)
    if isstatic(x)
        return LinSRange(-r.start, -r.stop, length(r))
    else
        return LinMRange(-r.start, -r.stop, length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::LinMRange)
    return LinMRange(-r.start, -r.stop, length(r))
end


function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Real, r::UnitSRange)
    if isstatic(x)
        return srange(x + first(r), length=length(r))
    else
        return mrange(x + first(r), length=length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Real, r::UnitMRange)
    return mrange(x + first(r), length=length(r))
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::UnitSRange, x::Real)
    if isstatic(x)
        return srange(first(r) + x, length=length(r))
    else
        return mrange(first(r) + x, length=length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::UnitMRange, x::Real)
    return mrange(x + first(r), length=length(r))
end
# For #18336 we need to prevent promotion of the step type: TODO
#Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::AbstractRange, x::Number) = range(first(r) + x, step=step(r), length=length(r))
#Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Number, r::AbstractRange) = range(x + first(r), step=step(r), length=length(r))


function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::StepSRangeLen{T}, x::Number) where T
    if isstatic(x)
        return StepSRangeLen{typeof(T(r.ref)+x)}(r.ref+x, r.step, length(r), r.offset)
    else
        return StepMRangeLen{typeof(T(r.ref)+x)}(r.ref+x, r.step, length(r), r.offset)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::StepMRangeLen{T}, x::Number) where T
    return StepMRangeLen{typeof(T(r.ref)+x)}(r.ref+x, r.step, length(r), r.offset)
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Number, r::StepSRangeLen{T}) where T
    if isstatic(x)
        return StepSRangeLen{typeof(x+T(r.ref))}(x + r.ref, r.step, length(r), r.offset)
    else
        return StepMRangeLen{typeof(x+T(r.ref))}(x + r.ref, r.step, length(r), r.offset)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Number, r::StepMRangeLen{T}) where T
    return StepMRangeLen{typeof(x+T(r.ref))}(x + r.ref, r.step, length(r), r.offset)
end


function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::LinSRange, x::Number)
    if isstatic(x)
        return LinSRange(r.start + x, r.stop + x, length(r))
    else
        return LinMRange(r.start + x, r.stop + x, length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::LinMRange, x::Number)
    return LinMRange(r.start + x, r.stop + x, length(r))
end


function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Number, r::LinSRange)
    if isstatic(x)
        return LinSRange(x + r.start, x + r.stop, length(r))
    else
        return LinMRange(x + r.start, x + r.stop, length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Number, r::LinMRange)
    return LinMRange(x + r.start, x + r.stop, length(r))
end

## TODO
#Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r1::AbstractRange, r2::AbstractRange) = r1 + r2
##

###
### :(-)
###
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::Union{UnitSRange,OneToSRange}, x::Number)
    if isstatic(x)
        return range(first(r)-x, length=length(r))
    else
        return range(first(r)-x, length=length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::Union{UnitMRange,OneToMRange}, x::Number)
    return range(first(r)-x, length=length(r))
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::StepSRange, x::Number)
    if isstatic(x)
        return mrange(first(r)-x, step=step(r), length=length(r))
    else
        return mrange(first(r)-x, step=step(r), length=length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::StepMRange, x::Number)
    return mrange(first(r)-x, step=step(r), length=length(r))
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), x::Number, r::StepSRange)
    if isstatic(x)
        return srange(x-first(r), step=-step(r), length=length(r))
    else
        return mrange(x-first(r), step=-step(r), length=length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), x::Number, r::StepMRange)
    return mrange(x-first(r), step=-step(r), length=length(r))
end


function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::StepSRangeLen{T}, x::Number) where T
    if isstatic(x)
        return StepSRangeLen{typeof(T(r.ref)-x)}(r.ref - x, r.step, length(r), r.offset)
    else
        return StepMRangeLen{typeof(T(r.ref)-x)}(r.ref - x, r.step, length(r), r.offset)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::StepMRangeLen{T}, x::Number) where T
    return StepMRangeLen{typeof(T(r.ref)-x)}(r.ref - x, r.step, length(r), r.offset)
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), x::Number, r::StepSRangeLen{T}) where T
    if isstatic(x)
        return StepSRangeLen{typeof(x-T(r.ref))}(x - r.ref, -r.step, length(r), r.offset)
    else
        return StepMRangeLen{typeof(x-T(r.ref))}(x - r.ref, -r.step, length(r), r.offset)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), x::Number, r::StepMRangeLen{T}) where T
    return StepMRangeLen{typeof(x-T(r.ref))}(x - r.ref, -r.step, length(r), r.offset)
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::LinSRange, x::Number)
    if isstatic(x)
        return LinMRange(r.start - x, r.stop - x, length(r))
    else
        return LinMRange(r.start - x, r.stop - x, length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::LinMRange, x::Number)
    return LinMRange(r.start - x, r.stop - x, length(r))
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), x::Number, r::LinSRange)
    if isstatic(x)
        return LinMRange(x - r.start, x - r.stop, length(r))
    else
        return LinMRange(x - r.start, x - r.stop, length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), x::Number, r::LinMRange)
    return LinMRange(x - r.start, x - r.stop, length(r))
end
# TODO
#function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r1::AbstractRange, r2::AbstractRange)
#    r1 - r2
#end

###
### :(*)
###
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::Number, r::Union{StepSRange,UnitSRange,OneToSRange})
    if isstatic(x)
        return mrange(x*first(r), step=x*step(r), length=length(r))
    else
        return mrange(x*first(r), step=x*step(r), length=length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::Number, r::Union{StepMRange,UnitMRange,OneToMRange})
    return mrange(x*first(r), step=x*step(r), length=length(r))
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::Number, r::StepSRangeLen{T}) where {T}
    if isstatic(x)
        return StepSRangeLen{typeof(x*T(r.ref))}(x*r.ref, x*r.step, length(r), r.offset)
    else
        return StepMRangeLen{typeof(x*T(r.ref))}(x*r.ref, x*r.step, length(r), r.offset)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::Number, r::StepMRangeLen{T}) where {T}
    return StepMRangeLen{typeof(x*T(r.ref))}(x*r.ref, x*r.step, length(r), r.offset)
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::Number, r::LinSRange)
    if isstatic(x)
        return LinSRange(x * r.start, x * r.stop, r.len)
    else
        return LinMRange(x * r.start, x * r.stop, r.len)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::Number, r::LinMRange)
    return LinMRange(x * r.start, x * r.stop, r.len)
end
# separate in case of noncommutative multiplication

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::Union{StepSRange,UnitSRange,OneToSRange}, x::Number)
    if isstatic(x)
        return srange(first(r)*x, step=step(r)*x, length=length(r))
    else
        return mrange(first(r)*x, step=step(r)*x, length=length(r))
    end
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::Union{StepMRange,UnitMRange,OneToMRange}, x::Number)
    return mrange(first(r)*x, step=step(r)*x, length=length(r))
end


function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::StepSRangeLen{T}, x::Number) where {T}
    if isstatic(x)
        return StepSRangeLen{typeof(T(r.ref)*x)}(r.ref*x, r.step*x, length(r), r.offset)
    else
        return StepMRangeLen{typeof(T(r.ref)*x)}(r.ref*x, r.step*x, length(r), r.offset)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::StepMRangeLen{T}, x::Number) where {T}
    return StepMRangeLen{typeof(T(r.ref)*x)}(r.ref*x, r.step*x, length(r), r.offset)
end


function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::LinSRange, x::Number)
    if isstatic(x)
        return LinMRange(r.start * x, r.stop * x, r.len)
    else
        return LinMRange(r.start * x, r.stop * x, r.len)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::LinMRange, x::Number)
    return LinMRange(r.start * x, r.stop * x, r.len)
end


###
### :(/)
###
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(/), r::Union{StepSRange,UnitSRange,OneToSRange}, x::Number)
    if isstatic(x)
        return srange(first(r)/x, step=step(r)/x, length=length(r))
    else
        return mrange(first(r)/x, step=step(r)/x, length=length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(/), r::Union{StepMRange,UnitMRange,OneToMRange}, x::Number)
    return mrange(first(r)/x, step=step(r)/x, length=length(r))
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(/), r::StepSRangeLen{T}, x::Number) where {T}
    if isstatic(x)
        return StepMRangeLen{typeof(T(r.ref)/x)}(r.ref/x, r.step/x, length(r), r.offset)
    else
        return StepMRangeLen{typeof(T(r.ref)/x)}(r.ref/x, r.step/x, length(r), r.offset)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(/), r::StepMRangeLen{T}, x::Number) where {T}
    return StepMRangeLen{typeof(T(r.ref)/x)}(r.ref/x, r.step/x, length(r), r.offset)
end


function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(/), r::LinSRange, x::Number)
    if isstatic(x)
        return LinSRange(r.start / x, r.stop / x, r.len)
    else
        return LinMRange(r.start / x, r.stop / x, r.len)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(/), r::LinMRange, x::Number)
    return LinMRange(r.start / x, r.stop / x, r.len)
end


###
### :(\)
###

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(\), x::Number, r::Union{StepSRange,UnitSRange,OneToSRange})
    if isstatic(x)
        return srange(x\first(r), step=x\step(r), length=length(r))
    else
        return mrange(x\first(r), step=x\step(r), length=length(r))
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(\), x::Number, r::Union{StepMRange,UnitMRange,OneToMRange})
    return mrange(x\first(r), step=x\step(r), length=length(r))
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(\), x::Number, r::StepSRangeLen)
    if isstatic(x)
        return StepSRangeLen(x\r.ref, x\r.step, length(r), r.offset)
    else
        return StepMRangeLen(x\r.ref, x\r.step, length(r), r.offset)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(\), x::Number, r::StepMRangeLen)
    return StepMRangeLen(x\r.ref, x\r.step, length(r), r.offset)
end

function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(\), x::Number, r::LinSRange)
    if isstatic(x)
        return LinSRange(x \ r.start, x \ r.stop, r.len)
    else
        return LinMRange(x \ r.start, x \ r.stop, r.len)
    end
end
function Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(\), x::Number, r::LinMRange)
    return LinMRange(x \ r.start, x \ r.stop, r.len)
end

#=
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(big), r::UnitRange) = big(r.start):big(last(r))
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(big), r::StepRange) = big(r.start):big(r.step):big(last(r))
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(big), r::StepRangeLen) = StepRangeLen(big(r.ref), big(r.step), length(r), r.offset)
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(big), r::LinRange) = LinRange(big(r.start), big(r.stop), length(r))
=#
