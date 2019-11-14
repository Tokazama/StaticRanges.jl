Base.show(io::IO, r::OneToRange) = print(io, typeof(r).name, "(", last(r), ")")

function Base.show(io::IO, r::AbstractStepRangeLen)
    print(io, typeof(r).name, "(", first(r), ":", step(r), ":", last(r), ")")
end

function Base.show(io::IO, r::StepMRange)
    print(io, "StepMRange(", first(r), ":", step(r), ":", last(r), ")")
end

function Base.show(io::IO, r::StepSRange)
    print(io, "StepSRange(", first(r), ":", step(r), ":", last(r), ")")
end

function Base.show(io::IO, r::StaticUnitRange)
    print(io, typeof(r).name, "(", repr(first(r)), ':', repr(last(r)), ")")
end

