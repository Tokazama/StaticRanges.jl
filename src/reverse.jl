@inline Base.reverse(r::OrdinalSRange) = (:)(slast(r), -sstep(r), sfirst(r))

@inline function Base.reverse(r::StepSRangeLen)
    # If `r` is empty, `length(r) - r.offset + 1 will be nonpositive hence
    # invalid. As `reverse(r)` is also empty, any offset would work so we keep
    # `r.offset`
    offset = isempty(r) ? soffset(r) : slength(r) - soffset(r) + SOne
    StepSRangeLen(sfirst(r), -sstep(r), slength(r), offset)
end

Base.reverse(r::LinSRange)     = LinRange(slast(r), sfirst(r), slength(r))