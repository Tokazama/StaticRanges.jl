
#broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::OrdinalRange) = r
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::StepRangeLen) = r
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::LinRange) = r

#broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::OrdinalRange) = range(-first(r), step=-step(r), length=length(r))
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::StaticStepRangeLen) = -r
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::StaticLinRange) = -r

Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Real, r::UnitMRange) = mrange(x + first(r), length=length(r))
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Real, r::UnitSRange) = srange(x + first(r), length=length(r))

Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::UnitMRange, x::Real) = mrange(first(r) + x, length=length(r))
Base.broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::UnitSRange, x::Real) = srange(first(r) + x, length=length(r))

# For #18336 we need to prevent promotion of the step type:
#broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::AbstractRange, x::Number) = range(first(r) + x, step=step(r), length=length(r))
#broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Number, r::AbstractRange) = range(x + first(r), step=step(r), length=length(r))
function broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::StepMRangeLen{T}, x::Number) where T =
    StepMRangeLen{typeof(T(r.ref)+x)}(r.ref + x, r.step, length(r), r.offset)
end
function broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::StepMRangeLen{T}, x::Number) where T =
    StepMRangeLen{typeof(T(r.ref)+x)}(r.ref + x, r.step, length(r), r.offset)
end

broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Number, r::StepRangeLen{T}) where T =
    StepRangeLen{typeof(x+T(r.ref))}(x + r.ref, r.step, length(r), r.offset)
broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r::LinRange, x::Number) = LinRange(r.start + x, r.stop + x, length(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(+), x::Number, r::LinRange) = LinRange(x + r.start, x + r.stop, length(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(+), r1::AbstractRange, r2::AbstractRange) = r1 + r2

broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::AbstractUnitRange, x::Number) = range(first(r)-x, length=length(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::AbstractRange, x::Number) = range(first(r)-x, step=step(r), length=length(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(-), x::Number, r::AbstractRange) = range(x-first(r), step=-step(r), length=length(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::StepRangeLen{T}, x::Number) where T =
    StepRangeLen{typeof(T(r.ref)-x)}(r.ref - x, r.step, length(r), r.offset)
broadcasted(::DefaultArrayStyle{1}, ::typeof(-), x::Number, r::StepRangeLen{T}) where T =
    StepRangeLen{typeof(x-T(r.ref))}(x - r.ref, -r.step, length(r), r.offset)
broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::LinRange, x::Number) = LinRange(r.start - x, r.stop - x, length(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(-), x::Number, r::LinRange) = LinRange(x - r.start, x - r.stop, length(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r1::AbstractRange, r2::AbstractRange) = r1 - r2

broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::Number, r::AbstractRange) = range(x*first(r), step=x*step(r), length=length(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::Number, r::StepRangeLen{T}) where {T} =
    StepRangeLen{typeof(x*T(r.ref))}(x*r.ref, x*r.step, length(r), r.offset)
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), x::Number, r::LinRange) = LinRange(x * r.start, x * r.stop, r.len)
# separate in case of noncommutative multiplication
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::AbstractRange, x::Number) = range(first(r)*x, step=step(r)*x, length=length(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::StepRangeLen{T}, x::Number) where {T} =
    StepRangeLen{typeof(T(r.ref)*x)}(r.ref*x, r.step*x, length(r), r.offset)
broadcasted(::DefaultArrayStyle{1}, ::typeof(*), r::LinRange, x::Number) = LinRange(r.start * x, r.stop * x, r.len)

broadcasted(::DefaultArrayStyle{1}, ::typeof(/), r::AbstractRange, x::Number) = range(first(r)/x, step=step(r)/x, length=length(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(/), r::StepRangeLen{T}, x::Number) where {T} =
    StepRangeLen{typeof(T(r.ref)/x)}(r.ref/x, r.step/x, length(r), r.offset)
broadcasted(::DefaultArrayStyle{1}, ::typeof(/), r::LinRange, x::Number) = LinRange(r.start / x, r.stop / x, r.len)

broadcasted(::DefaultArrayStyle{1}, ::typeof(\), x::Number, r::AbstractRange) = range(x\first(r), step=x\step(r), length=length(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(\), x::Number, r::StepRangeLen) = StepRangeLen(x\r.ref, x\r.step, length(r), r.offset)
broadcasted(::DefaultArrayStyle{1}, ::typeof(\), x::Number, r::LinRange) = LinRange(x \ r.start, x \ r.stop, r.len)

broadcasted(::DefaultArrayStyle{1}, ::typeof(big), r::UnitRange) = big(r.start):big(last(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(big), r::StepRange) = big(r.start):big(r.step):big(last(r))
broadcasted(::DefaultArrayStyle{1}, ::typeof(big), r::StepRangeLen) = StepRangeLen(big(r.ref), big(r.step), length(r), r.offset)
broadcasted(::DefaultArrayStyle{1}, ::typeof(big), r::LinRange) = LinRange(big(r.start), big(r.stop), length(r))
