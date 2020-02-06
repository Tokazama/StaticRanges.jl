
###
### AbstractAxis
###
promote_values_rule(::X, ::Y) where {X,Y} = promote_values_rule(X, Y)
function promote_values_rule(::Type{X}, ::Type{Y}) where {X<:AbstractAxis,Y<:AbstractAxis}
    xv = values_type(X)
    yv = values_type(Y)
    return same_type(xv, yv) ? xv : _promote_rule(xv, yv)
end
promote_values_rule(::Type{X}, ::Type{Y}) where {X,Y} = _promote_rule(X, Y)

promote_keys_rule(::X, ::Y) where {X,Y} = promote_keys_rule(X, Y)
function promote_keys_rule(::Type{X}, ::Type{Y}) where {X<:AbstractAxis,Y<:AbstractAxis}
    xv = keys_type(X)
    yv = keys_type(Y)
    return same_type(xv, yv) ? xv : _promote_rule(xv, yv)
end

promote_axis_rule(::X, ::Y) where {X,Y} = promote_axis_rule(X, Y)
promote_axis_rule(::Type{X}, ::Type{Y}) where {X<:Axis,Y<:AbstractAxis} = Axis
promote_axis_rule(::Type{X}, ::Type{Y}) where {X<:AbstractAxis,Y<:Axis} = Axis
promote_axis_rule(::Type{X}, ::Type{Y}) where {X<:Axis,Y<:Axis} = Axis
promote_axis_rule(::Type{X}, ::Type{Y}) where {X<:Axis,Y<:SimpleAxis} = Axis
promote_axis_rule(::Type{X}, ::Type{Y}) where {X<:SimpleAxis,Y<:Axis} = Axis
promote_axis_rule(::Type{X}, ::Type{Y}) where {X<:SimpleAxis,Y<:AbstractAxis} = SimpleAxis
promote_axis_rule(::Type{X}, ::Type{Y}) where {X<:AbstractAxis,Y<:SimpleAxis} = SimpleAxis
promote_axis_rule(::Type{X}, ::Type{Y}) where {X<:SimpleAxis,Y<:SimpleAxis} = SimpleAxis

function _promote_rule(::Type{X}, ::Type{Y}) where {X,Y}
    out = promote_rule(X, Y)
    return out <: Union{} ? promote_rule(Y, X) : out
end

function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:AbstractAxis,Y<:AbstractAxis}
    return promote_axis_rule(X,Y){
        promote_type(keytype(X),keytype(X)),
        promote_type(valtype(X),valtype(X)),
        _promote_rule(keys_type(X),keys_type(Y)),
        _promote_rule(values_type(X),values_type(Y))}
end

function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:SimpleAxis,Y<:SimpleAxis}
    return SimpleAxis{promote_type(valtype(X),valtype(Y)), _promote_rule(values_type(X),values_type(Y))}
end

#=
Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:AbstractAxis,Y<:Axis} = promote_rule(Y, X)
function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:Axis,Y<:AbstractAxis}
    return Axis{promote_type(keytype(X),keytype(Y)),
                promote_type(valtype(X),valtype(Y)),
                _promote_rule(keys_type(X),keys_type(Y)),
                _promote_rule(values_type(X),values_type(Y))}
end
function Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:Axis,Y<:Axis}
    return Axis{promote_type(keytype(X),keytype(Y)),
                promote_type(valtype(X),valtype(Y)),
                _promote_rule(keys_type(X),keys_type(Y)),
                _promote_rule(values_type(X),values_type(Y))}
end
=#

#Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:AbstractAxis,Y<:AbstractUnitRange} = promote_rule(X, similar_type(X, index_keys_type(Y),Y))
#Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:UnitRange,Y<:AbstractAxis} = promote_rule(Y, X)

Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:AbstractVector,Y<:AbstractAxis} = promote_rule(Y, X)
Base.promote_rule(::Type{X}, ::Type{Y}) where {X<:AbstractAxis,Y<:AbstractVector} = promote_rule(values_type(X), Y)

# TODO
# MethodError: no method matching similar_type(::Type{SimpleAxis{nothing,Int64,UnitMRange{Int64}}}, ::Type{UnitMRange{Int64}}, ::Type{UnitMRange{Int64}})

function same_type(::Type{X}, ::Type{Y}) where {X<:AbstractAxis,Y<:AbstractAxis}
    return (X.name === Y.name)  & # TODO there should be a better way of doing this
       same_type(keys_type(X), keys_type(Y)) &
       same_type(values_type(X), values_type(Y))
end
