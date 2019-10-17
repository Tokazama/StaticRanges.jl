
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


for RANGE_TYPE in (:OneTo,:OneToMRange,:OneToSRange)
    @eval begin
        function similar_type(
            ::$(RANGE_TYPE){T,S},
            element_type=T,
           ) where {T,R,S}
            return $(RANGE_TYPE){element_type}
        end
    end
end

for RANGE_TYPE in (:UnitRange,:UnitRangeMRange,:UnitRangeSRange)
    @eval begin
        function similar_type(
            ::$(RANGE_TYPE){T,S},
            element_type=T,
           ) where {T,R,S}
            return $(RANGE_TYPE){element_type}
        end
    end
end

for RANGE_TYPE in (:LinRange,:LinMRange,:LinSRange)
    @eval begin
        function similar_type(
            ::$(RANGE_TYPE){T,S},
            element_type=T,
           ) where {T,R,S}
            return $(RANGE_TYPE){element_type}
        end
    end
end

for RANGE_TYPE in (:StepRangeLen,:StepMRangeLen,:StepSRangeLen)
    @eval begin
        function similar_type(
            ::$(RANGE_TYPE){T,R,S},
            element_type=T,
            reference_type=R,
            step_type=S
           ) where {T,R,S}
            return $(RANGE_TYPE){element_type,reference_type,step_type}
        end
    end
end

for RANGE_TYPE in (:StepRange,:StepMRange,:StepSRange)
    @eval begin
        function similar_type(
            ::$(RANGE_TYPE){T,S},
            element_type=T,
            step_type=S
           ) where {T,R,S}
            return $(RANGE_TYPE){element_type,step_type}
        end
    end
end
