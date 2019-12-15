

#=
Switch traits are used for to pass information that can't be known based on
an objects type. For example, a method may require paramter checks for
construction that may have been previously completed incidently.

A concrete example is the LengthCheck trait


=#
abstract type ParamCheck{B} end

is_checked(::P) where {P} = is_checked(P)
is_checked(::Type{<:ParamCheck{B}}) where {B} = B


function checkparams(p::P, args...; kwargs...) where {P<:ParamCheck}
    return is_checked(P) ? nothing : p(args...; kwargs...)
end

(p::ParamCheck{true})(args...; kwargs...) = nothing
(p::ParamCheck{false})(args...; kwargs...) = execute_check(p, args...; kwargs...)










