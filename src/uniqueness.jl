abstract type Uniqueness end

struct AllUniqueTrait <: Uniqueness end
const AllUnique = AllUniqueTrait()

struct NotUniqueTrait <: Uniqueness end
const NotUnique = NotUniqueTrait()

struct UnkownUniqueTrait <: Uniqueness end
const UnkownUnique = UnkownUniqueTrait()

Uniqueness(::T) where {T} = Uniqueness(T)
Uniqueness(::Type{T}) where {T} = UnkownUnique
Uniqueness(::Type{T}) where {T<:AbstractRange} = AllUnique


