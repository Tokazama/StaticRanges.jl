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

function check_index_uniqueness(idx::AbstractIndices, u::Uniqueness=NotUnique)
    return _check_index_uniqueness(keys(idx), u)
end
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

# length checks
abstract type AbstractLengthCheck end

struct LengthCheckedTrait <: AbstractLengthCheck end
const LengthChecked = LengthCheckedTrait()

struct LengthNotCheckedTrait <: AbstractLengthCheck end
const LengthNotChecked = LengthNotCheckedTrait()

function check_index_length(axs, idx, lc::AbstractLengthCheck=LengthNotChecked)
    return _check_length(axs, idx, lc)
end

_check_length(axs, idx, ::LengthCheckedTrait) = nothing

function _check_length(axs, idx, ::LengthNotCheckedTrait)
    if length(axs) == length(idx)
        return nothing
    else
        error("Length of parent axes and index must be of equal length, got an
               axis of length $(length(axs)) and index of length $(length(idx)).")
    end
end

