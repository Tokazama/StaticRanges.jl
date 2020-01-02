
# uniqueness checks
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

#=
function check_index_uniqueness(idx::AbstractAxis, u::Uniqueness=NotUnique)
    return _check_index_uniqueness(keys(idx), u)
end
=#

function check_index_uniqueness(idx, u::Uniqueness=NotUnique)
    return _check_index_uniqueness(idx, u)
end

_check_index_uniqueness(idx, ::AllUniqueTrait) = nothing
function _check_index_uniqueness(idx, ::UnkownUniqueTrait)
    return allunique(idx) ? nothing : _check_index_uniqueness(idx, NotUnique)
end
function _check_index_uniqueness(idx, ::NotUniqueTrait)
    error("all keys of each index must be unique.")
end

