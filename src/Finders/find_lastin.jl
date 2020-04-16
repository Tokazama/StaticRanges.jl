
function find_lastin(span::AbstractUnitRange{<:Integer}, r::AbstractRange{<:Integer})
    fspan = first(span)
    lspan = last(span)
    fr = first(r)
    lr = last(r)
    sr = step(r)
    if sr > 0
        if lr <= lspan
            return length(r)
        else
            return length(r) - ceil(Integer, (lr - lspan) / sr)
        end
    elseif sr < 0
        if lr >= fspan
            return length(r)
        else
            return length(r) - ceil(Integer, (lr - fspan) / sr)
        end
    else
        if fr <= lspan
            return length(r)
        else
            return 0
        end
    end
end

function find_lastin(x::AbstractVector{T1}, y::AbstractVector{T2}) where {T1,T2}
    out = 0
    if (step(x) > zerounit(T1)) & (step(y) > zerounit(T2))
        for x_i in reverse(x)
            idx = find_firsteq(x_i, y)
            if !isa(idx, Nothing)
                out = idx
                break
            end
        end
    else
        for x_i in reverse(x)
            idx = find_lasteq(x_i, y)
            if !isa(idx, Nothing)
                out = idx
                break
            end
        end
    end
    return out
end
