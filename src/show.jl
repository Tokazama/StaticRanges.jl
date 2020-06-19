
Base.show(io::IO, r::OneToSRange) = print(io, "OneToSRange($(last(r)))")

Base.show(io::IO, r::OneToMRange) = print(io, "OneToMRange($(last(r)))")

function Base.show(io::IO, r::AbstractStepRangeLen)
    print(io, typeof(r).name, "(", first(r), ":", step(r), ":", last(r), ")")
end

function Base.show(io::IO, r::StepMRange)
    print(io, "StepMRange(", first(r), ":", step(r), ":", last(r), ")")
end

function Base.show(io::IO, r::StepSRange)
    print(io, "StepSRange(", first(r), ":", step(r), ":", last(r), ")")
end

function Base.show(io::IO, r::UnitSRange)
    print(io, "UnitSRange(", repr(first(r)), ':', repr(last(r)), ")")
end

function Base.show(io::IO, r::UnitMRange)
    print(io, "UnitMRange(", repr(first(r)), ':', repr(last(r)), ")")
end

function Base.show(io::IO, r::AbstractLinRange)
    if is_static(r)
        print(io, "LinSRange(")
    else
        print(io, "LinMRange(")
    end
    show(io, first(r))
    print(io, ", stop=")
    show(io, last(r))
    print(io, ", length=")
    show(io, length(r))
    print(io, ')')
end

