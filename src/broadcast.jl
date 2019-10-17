
Base.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::typeof(+), r::Union{SRange{T},MRange{T}}) where {T} = r
Base.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::typeof(-), r::Union{SRange{T},MRange{T}}) where {T} = -r

for (ftype,f) in ((:(typeof(+)), :(+)),
                  (:(typeof(-)), :(-)),
                  (:(typeof(*)), :(*)),
                  (:(typeof(/)), :(/)))
    for (T) in (:OneToSRange,:StepSRange,:LinSRange,:StepSRangeLen)
        @eval begin
            Base.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::$ftype, r::$T, x::Number) = _broadcast(StaticTrait(x), $f, r, x)
            Base.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::$ftype, x::Number, r::$T) = _broadcast(StaticTrait(x), $f, x, r)
        end
    end

    @eval begin
        Base.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::$ftype, r::UnitSRange, x::Real) = _broadcast(StaticTrait(x), $f, r, x)
        Base.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::$ftype, x::Real, r::UnitSRange) = _broadcast(StaticTrait(x), $f, x, r)
    end
end

for (ftype,f) in ((:(typeof(+)), :(+)),
                  (:(typeof(-)), :(-)),
                  (:(typeof(*)), :(*)),
                  (:(typeof(/)), :(/)))

    for (T) in (:OneToMRange,:StepMRange,:LinMRange,:StepMRangeLen)
        @eval begin
            Base.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::$ftype, r::$T, x::Number) = _broadcast(IsNotStatic, $f, r, x)
            Base.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::$ftype, x::Number, r::$T) = _broadcast(IsNotStatic, $f, x, r)
        end
    end


    @eval begin
        Base.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::$ftype, r::UnitMRange, x::Real) = _broadcast(IsNotStatic, $f, r, x)
        Base.broadcasted(::Broadcast.DefaultArrayStyle{1}, ::$ftype, x::Real, r::UnitMRange) = _broadcast(IsNotStatic, $f, x, r)
    end
end


###
### StaticUnitRange
###
function _broadcast(::IsStaticTrait, ::typeof(+), x, r::Union{UnitSRange,OneToSRange})
    return srange(+(x, first(r)), length=length(r))
end
function _broadcast(::IsNotStaticTrait, ::typeof(+), x, r::StaticUnitRange)
    return mrange(+(x, first(r)), length=length(r))
end
# f(::StaticUnitRange, x)
function _broadcast(::IsStaticTrait, ::typeof(+), r::Union{UnitSRange,OneToSRange}, x)
    return srange(+(first(r), x), length=length(r))
end
function _broadcast(::IsNotStaticTrait, ::typeof(+), r::StaticUnitRange, x)
    return mrange(+(first(r), x), length=length(r))
end

function _broadcast(::IsStaticTrait, f, x, r::Union{UnitSRange{T},OneToSRange{T}}) where {T}
    return srange(f(x, first(r)), step=f(one(T)), length=length(r))
end
function _broadcast(::IsNotStaticTrait, f, x, r::StaticUnitRange{T}) where {T}
    return mrange(f(x, first(r)), step=f(one(T)), length=length(r))
end
# f(::StaticUnitRange, x)
function _broadcast(::IsStaticTrait, f, r::Union{UnitSRange,OneToSRange}, x)
    return srange(f(first(r), x), length=length(r))
end
function _broadcast(::IsNotStaticTrait, f, r::StaticUnitRange, x)
    return mrange(f(first(r), x), length=length(r))
end

###
### AbstractStepRange
###
# f(x, ::AbstractStepRange)
function _broadcast(::IsStaticTrait, f, x, r::StepSRange)
    return srange(f(x, first(r)), step=step(r), length=length(r))
end
function _broadcast(::IsNotStaticTrait, f, x, r::AbstractStepRange)
    return mrange(f(x, first(r)), step=step(r), length=length(r))
end
# f(::AbstractStepRange, x)
function _broadcast(::IsStaticTrait, f, r::StepSRange, x)
    return srange(f(first(r), x), step=step(r), length=length(r))
end
function _broadcast(::IsNotStaticTrait, f, r::AbstractStepRange, x)
    return mrange(f(first(r), x), step=step(r), length=length(r))
end

###
### StepRangeLen
###
# f(x, ::AbstractStepRangeLen)
function _broadcast(::IsStaticTrait, f::Function, x, r::StepSRangeLen{T}) where {T}
    return StepSRangeLen{typeof(f(x, T(r.ref)))}(f(x, r.ref), r.step, length(r), r.offset)
end
function _broadcast(::IsNotStaticTrait, f::Function, x, r::AbstractStepRangeLen{T}) where {T}
    return StepMRangeLen{typeof(f(x, T(r.ref)))}(f(x, r.ref), r.step, length(r), r.offset)
end
# f(::AbstractStepRangeLen, x)
function _broadcast(::IsStaticTrait, f::Function, r::StepSRangeLen, x)
    return StepSRangeLen{typeof(f(T(r.ref), x))}(f(r.ref, x), r.step, length(r), r.offset)
end
function _broadcast(::IsNotStaticTrait, f::Function, r::AbstractStepRangeLen, x)
    return StepMRangeLen{typeof(f(T(r.ref), x))}(f(r.ref, x), r.step, length(r), r.offset)
end

###
### AbstractLinRange
###
# f(x, ::AbstractLinRange)
function _broadcasted(::IsStaticTrait, f::Function, x, r::LinSRange)
    return LinSRange(f(x, r.start), f(x, r.stop), length(r))
end
function _broadcasted(::IsNotStaticTrait, f::Function, x, r::AbstractLinRange)
    return LinMRange(f(x, r.start), f(x, r.stop), length(r))
end
# f(::AbstractLinRange, x)
function _broadcasted(::IsStaticTrait, f::Function, r::LinSRange, x)
    return LinSRange(f(r.start, x), f(r.stop, x), length(r))
end
function _broadcasted(::IsNotStaticTrait, f::Function, r::AbstractLinRange, x)
    return LinMRange(f(r.start, x), f(r.stop, x), length(r))
end

#=
for (ftype,f) in ((:(typeof(+)), :+),
                  (:(typeof(-)), :-),
                  (:(typeof(*)), :*),
                  (:(typeof(/)), :/))
    @eval begin
        ###
        ### StaticUnitRange
        ###
        # f(x, ::StaticUnitRange)
        function _broadcast(::IsStaticTrait, ::$(ftype), x, r::UnitSRange)
            return srange($(f)(x, first(r)), length=length(r))
        end
        function _broadcast(::IsNotStaticTrait, ::$(ftype), x, r::StaticUnitRange)
            return mrange($(f)($(f)(x, first(r))), length=length(r))
        end
        # f(::StaticUnitRange, x)
        function _broadcast(::IsStaticTrait, ::$(ftype), r::UnitSRange, x)
            return srange($(f)(first(r), x), length=length(r))
        end
        function _broadcast(::IsNotStaticTrait, ::$(ftype), r::StaticUnitRange, x)
            return mrange($(f)(first(r), x), length=length(r))
        end

        ###
        ### AbstractStepRange
        ###
        # f(x, ::AbstractStepRange)
        function _broadcast(::IsStaticTrait, ::$(ftype), x, r::StepSRange)
            return srange($(f)(x, first(r)), step=step(r), length=length(r))
        end
        function _broadcast(::IsNotStaticTrait, ::$(ftype), x, r::AbstractStepRange)
            return mrange($(f)(x, first(r)), step=step(r), length=length(r))
        end
        # f(::AbstractStepRange, x)
        function _broadcast(::IsStaticTrait, ::$(ftype), r::StepSRange, x)
            return srange($(f)(first(r), x), step=step(r), length=length(r))
        end
        function _broadcast(::IsNotStaticTrait, ::$(ftype), r::AbstractStepRange, x)
            return mrange($(f)(first(r), x), step=step(r), length=length(r))
        end

        ###
        ### StepRangeLen
        ###
        # f(x, ::AbstractStepRangeLen)
        function _broadcast(::IsStaticTrait, ::$(ftype), x, r::StepSRangeLen{T}) where {T}
            return StepSRangeLen{typeof($(f)(x, T(r.ref)))}($(f)(x, r.ref), r.step, length(r), r.offset)
        end
        function _broadcast(::IsNotStaticTrait, ::$(ftype), x, r::AbstractStepRangeLen{T}) where {T}
            return StepMRangeLen{typeof($(f)(x, T(r.ref)))}($(f)(x, r.ref), r.step, length(r), r.offset)
        end
        # f(::AbstractStepRangeLen, x)
        function _broadcast(::IsStaticTrait, ::$(ftype), r::StepSRangeLen, x)
            return StepSRangeLen{typeof($(f)(T(r.ref), x))}($(f)(r.ref, x), r.step, length(r), r.offset)
        end
        function _broadcast(::IsNotStaticTrait, ::$(ftype), r::AbstractStepRangeLen, x)
            return StepMRangeLen{typeof($(f)(T(r.ref), x))}($(f)(r.ref, x), r.step, length(r), r.offset)
        end

        ###
        ### AbstractLinRange
        ###
        # f(x, ::AbstractLinRange)
        function _broadcasted(::IsStaticTrait, ::$(ftype), x, r::LinSRange)
            return LinSRange($(f)(x, r.start), $(f)(x, r.stop), length(r))
        end
        function _broadcasted(::IsNotStaticTrait, ::$(ftype), x, r::AbstractLinRange)
            return LinMRange($(f)(x, r.start), $(f)(x, r.stop), length(r))
        end
        # f(::AbstractLinRange, x)
        function _broadcasted(::IsStaticTrait, ::$(ftype), r::LinSRange, x)
            return LinSRange($(f)(r.start, x), $(f)(r.stop, x), length(r))
        end
        function _broadcasted(::IsNotStaticTrait, ::$(ftype), r::AbstractLinRange, x)
            return LinMRange($(f)(r.start, x), $(f)(r.stop, x), length(r))
        end
    end
end
=#
