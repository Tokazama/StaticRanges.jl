

"""
    LinSRange
"""
struct LinSRange{T,B,E,L,D} <: StaticLinRange{T,B,E,L,D}

    function LinSRange{T}(start::SVal{B}, stop::SVal{E}, len::SInt64{L}) where {T,B,E,L}
        len >= SZero || throw(ArgumentError("range($B, stop=$E, length=$L): negative length"))
        if len == SOne
            start == stop || throw(ArgumentError("range($B, stop=$E, length=$L): endpoints differ"))
            return new{T,SVal{B,T},SVal{E,T},SVal{1,Int},SVal{1,Int}}()
        end
        new{T,SVal{B,T},SVal{E,T},SVal{L,Int},SVal{max(L-1,1),Int}}()
    end
end

"""
    LinMRange
"""
struct LinMRange{T,B,E,D} <: StaticLinRange{T,B,E,Dynamic,D}
    start::B
    stop::E
    lendiv::D
end

