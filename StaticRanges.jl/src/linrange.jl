
function linrange(::Type{T}, b::SVal{B,Tb}, e::SVal{E,Te}, l::SInteger{L}) where {T,B,Tb,E,Te,L}
    SRange{T,b,typeof(SVal{(E-B)/max(L - 1, 1)}()),E,L,1}()
end

function linrange(b::SVal{B}, e::SVal{E}, l::SVal{L}) where {B,E,L} 
    linrange(typeof((stop-start)/len), b, e, l)
end

function linspace(::Type{T}, b::SInteger{B}, e::SInteger{E}, l::SInteger{L}) where {T,B,E,L}
    linrange(T, b, e, l)
end