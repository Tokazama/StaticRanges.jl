
# TODO find_firstin
function _find_firstin_unit_int(span::AbstractUnitRange{<:Integer}, r::OrdinalRange{<:Integer})
    fspan = first(span)
    lspan = last(span)
    fr = first(r)
    lr = last(r)
    sr = step(r)
    if sr > 0
        if fr >= fspan
            return nothing
        else
            return ceil(Integer, (fspan - fr) / sr)+1
        end
    elseif sr < 0
        if fr <= lspan
            return nothing
        else
            return ceil(Integer, (lspan - fr) / sr) + 1
        end
    else
        if fr >= fspan
            return nothing
        else
            return length(r) + 1
        end
    end
end

function find_firstin(x::AbstractVector{T1}, y::AbstractVector{T2}) where {T1,T2}
    out = 1
    if (step(x) > zerounit(T1)) & (step(y) > zerounit(T2))
        for x_i in x
            idx = find_firsteq(x_i, y)
            if !isa(idx, Nothing)
                out = idx
                break
            end
        end
    else
        for x_i in x
            idx = find_lasteq(x_i, y)
            if !isa(idx, Nothing)
                out = idx
                break
            end
        end
    end
    return out
end
