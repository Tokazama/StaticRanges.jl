
Base.similar(r::OneToMRange, ::Type{T}) where {T} = OneToMRange{T}(last(r))
Base.similar(r::OneToSRange{T,L}, ::Type{T2}) where {T,L,T2} = OneToSRange{T,T(L)}()
# FIXME type piracy
Base.similar(r::OneTo, ::Type{T}) where {T} = OneTo{T}(last(r))

Base.similar(r::UnitMRange, ::Type{T}) where {T} = UnitMRange{T}(first(r), last(r))
Base.similar(r::UnitSRange{T,F,L}, ::Type{T2}) where {T,F,L,T2} = UnitSRange{T,T(F),T(L)}()
# FIXME type piracy
Base.similar(r::UnitRange, ::Type{T}) where {T} = UnitRange{T}(first(r), last(r))

Base.similar(r::StepMRange, ::Type{T}) where {T} = StepMRange{T}(first(r), step(r), last(r))
Base.similar(r::StepSRange, ::Type{T}) where {T} = StepSRange{T}(first(r), step(r), last(r))
# FIXME type piracy
Base.similar(r::StepRange, ::Type{T}) where {T} = StepRange{T}(first(r), step(r), last(r))

Base.similar(r::LinMRange, ::Type{T}) where {T} = LinMRange{T}(first(r), last(r), r.len)
Base.similar(r::LinSRange, ::Type{T}) where {T} = LinSRange{T}(first(r), last(r), r.len)
# FIXME type piracy
Base.similar(r::LinRange, ::Type{T}) where {T} = LinRange{T}(first(r), last(r), r.len)

Base.similar(r::StepMRangeLen, ::Type{T}) where {T} = StepMRangeLen{T}(r.ref, r.step, r.len, r.offset)
Base.similar(r::StepSRangeLen, ::Type{T}) where {T} = StepSRangeLen{T}(r.ref, r.step, r.len, r.offset)
# FIXME type piracy
Base.similar(r::StepRangeLen, ::Type{T}) where {T} = StepRangeLen{T}(r.ref, r.step, r.len, r.offset)
