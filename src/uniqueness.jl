"""
    Uniqueness
"""
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

"""
    all_unique(x, u::Uniqueness=UnkownUnique)

Functions similarly to `allunique` but provides the option to bypass checking
each element if this has already been checked or if it's already known at
compile time (e.g., ranges). Note that the default `UnkownUniqueTrait` is
treated like a wild card, so that whatever `Uniqueness(x)` returns determines
whether each element needs to be checked.
"""
function all_unique(x::T, u::Uniqueness=UnkownUnique) where {T}
    return _catch_all_unique(x, _all_unique(Uniqueness(T), u))
end
_all_unique(tu::U, u::U) where {U<:Uniqueness} = tu
_all_unique(::AllUniqueTrait, ::UnkownUniqueTrait) = AllUnique
_all_unique(::UnkownUniqueTrait, ::AllUniqueTrait) = AllUnique
_all_unique(::NotUniqueTrait, ::UnkownUniqueTrait) = NotUnique
_all_unique(::UnkownUniqueTrait, ::NotUniqueTrait) = NotUnique
_all_unique(::AllUniqueTrait, ::NotUniqueTrait) = error
_all_unique(::NotUniqueTrait, ::AllUniqueTrait) = error

_catch_all_unique(x, ::NotUniqueTrait) = false
_catch_all_unique(x, ::AllUniqueTrait) = true
_catch_all_unique(x, ::UnkownUniqueTrait) = allunique(x)
function _catch_all_unique(x::T, ::typeof(error)) where {T}
    error("$T cannot have it's uniqueness specified differently than what is
           determined at compile time. Consider not specifying  `u` in
           `all_unique`.")
end
