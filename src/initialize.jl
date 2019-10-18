
function init_range(::AbstractRange, start;  length::Union{Integer,Nothing}=nothing, stop=nothing, step=nothing)
    return Base._range(start, step, stop, length)
end

function init_range(::AbstractRange, start, stop; length::Union{Integer,Nothing}=nothing, step=nothing)
    return Base._range2(start, step, stop, length)
end

function init_range(::MRange, start;  length::Union{Integer,Nothing}=nothing, stop=nothing, step=nothing)
    return _mrange(start, step, stop, length)
end

function init_range(::MRange, start, stop; length::Union{Integer,Nothing}=nothing, step=nothing)
    return _mrange(start, step, stop, length)
end

function init_range(::SRange, start;  length::Union{Integer,Nothing}=nothing, stop=nothing, step=nothing)
    return _srange(start, step, stop, length)
end

function init_range(::SRange, start, stop; length::Union{Integer,Nothing}=nothing, step=nothing)
    return _srange(start, step, stop, length)
end

oneto(::OneTo, i) = OneTo(i)
oneto(::OneToMRange, i) = OneToMRange(i)
oneto(::OneToSRange, i) = OneToSRange(i)

unitrange(::UnitRange, start, stop) = UnitRange(start, stop)
unitrange(::UnitMRange, start, stop) = UnitMRange(start, stop)
unitrange(::UnitSRange, start, stop) = UnitSRange(start, stop)

steprange(::StepRange, start, step, stop) = StepRange(start, step, stop)
steprange(::StepMRange, start, step, stop) = StepMRange(start, step, stop)
steprange(::StepSRange, start, step, stop) = StepSRange(start, step, stop)

linrange(::LinRange, start, stop, len) = LinRange(start, stop, len)
linrange(::LinMRange, start, stop, len) = LinMRange(start, stop, len)
linrange(::LinSRange, start, stop, len) = LinSRange(start, stop, len)

steprangelen(::StepRangeLen, ref, step, len, offset) = StepRangeLen(ref, step, len, offset)
steprangelen(::StepRangeLen, ref, step, len) = StepRangeLen(ref, step, len)
steprangelen(::StepMRangeLen, ref, step, len, offset) = StepMRangeLen(ref, step, len, offset)
steprangelen(::StepMRangeLen, ref, step, len) = StepMRangeLen(ref, step, len)
steprangelen(::StepSRangeLen, ref, step, len, offset) = StepSRangeLen(ref, step, len, offset)
steprangelen(::StepSRangeLen, ref, step, len) = StepSRangeLen(ref, step, len)



