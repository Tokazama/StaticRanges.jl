Base.issorted(r::AbstractUnitSRange) = true
Base.issorted(r::AbstractSRange) = length(r) <= 1 || step(r) >= zero(step(r))

Base.sort(r::AbstractUnitSRange) = r
Base.sort!(r::AbstractUnitSRange) = r

Base.sort(r::AbstractSRange) = issorted(r) ? r : reverse(r)

Base.sortperm(r::AbstractUnitSRange) = SOne:Slength(r)
Base.sortperm(r::AbstractSRange) = issorted(r) ? (SOne:SOne:slength(r)) : (slength(r):-SOne:SOne)
