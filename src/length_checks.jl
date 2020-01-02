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
