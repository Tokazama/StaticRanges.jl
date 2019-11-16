
function Base.filter(f::Function, r::UnionRange)
    return isempty(r) ? Int[] : @inbounds(r[find_all(f, r)])
end

Base.filter(f::BitAnd, r::UnionRange) = _fltr_and(f, r, order(r))
_fltr_and(f, r, ro) = _fltr_and(r, ro, find_all(f.f1, r, ro), find_all(f.f2, r, ro))
function _fltr_and(r, ro, inds1, inds2)
    if isempty(inds1)
        return empty(r)
    else
        if isempty(inds2)
            return empty(r)
        else
            return @inbounds(r[intersect(inds1, inds2)])
        end
    end
end

Base.filter(f::BitOr, r::UnionRange) = _fltr_or(f, r, order(r))
_fltr_or(f, r, ro) = _fltr_or(r, ro, find_all(f.f1, r, ro), find_all(f.f2, r, ro))
function _fltr_or(r, ro, inds1, inds2)
    if isempty(inds1)
        if isempty(inds2)
            return empty(r)
        else
            return @inbounds(r[inds2])
        end
    else
        if isempty(inds2)
            return @inbounds(r[inds1])
        else
            if is_after(inds1, inds2)
                return vcat(@inbounds(inds2), @inbounds(inds1))
            elseif is_before(inds1, inds2)
                return vcat(@inbounds(r[inds1]), @inbounds(r[inds2]))
            else
                return @inbounds(r[_group_min(inds1, Forward, inds2, Forward):_group_max(inds1, Forward, inds2, Forward)])
            end

        end
    end
end


function Base.filter(f::Fix2{typeof(!=)}, r::UnionRange)
    return _fltr_not(r, find_all(<(f.x), x), find_all(>(f.x), x))
end

function _fltr_not(r, inds1, inds2)
    if isempty(inds1)
        if isempty(inds2)
            return empty(r)
        else
            return @inbounds(r[inds2])
        end
    else
        if isempty(inds2)
            return @inbounds(r[inds1])
        else
            return vcat(@inbounds(r[inds1]), @inbounds(r[inds2]))
        end
    end
end
