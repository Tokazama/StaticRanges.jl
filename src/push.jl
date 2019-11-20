"""
    push_key!(a::AbstractIndex{K}, k::K)
"""
function push_key!(a, k)
    is_dynamic(a) || error("$(typeof(a)) is not dynamic. Cannot change keys.")
    _push_key!(key_continuity(a), a, k)
    set_last!(values(a), last(a) + one(eltype(a)))
    return a
end

_push_key!(::DiscreteTrait, ks, k) = push!(ks, k)
function _push_key!(::ContinuousTrait, a, k)
    nextval(a, last(a)) == k
    set_length!(keys(a), length(a) + 1)
end
