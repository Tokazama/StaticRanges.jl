
push(v::AbstractVector{T}, item) where {T} = pushfirst(v, convert(T, item))

function push(v::AbstractVector{T}, item::T)  where {T}
    len = 
    out = similar(v, set_length(axes(v, 1), length(v) + 1))
    for i in eachindex(v)
        out[i] = v[i]
    end
    out[end] = item
    return out
end

pushfirst(v::AbstractVector{T}, item) where {T} = pushfirst(v, convert(T, item))

function pushfirst(v::AbstractVector{T}, item::T)  where {T}
    len = length(v) + 1
    out = similar(v, set_length(axes(v, 1), len))
    out[1] = item
    for i in 2:len
        out[i] = v[i - 1]
    end
    return out
end

