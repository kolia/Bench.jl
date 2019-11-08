module Args

import Random

struct Bencharg
    gen::Function
    minsize::NTuple{N,Int} where N
    tag

    function Bencharg(gen, minsize::NTuple{N,Int}, tag) where N
        @assert hasmethod(gen, typeof(minsize)) "gen must have a method accepting arguments of type Int"
        new(gen, minsize, tag)
    end
end

Bencharg(gen::Function, minsize::Int=1, tag=tag(gen(minsize))) = Bencharg(gen, (minsize,), tag)


show(io::IO, a::Bencharg) = print(io, "$(name(a)) with size ≥ $(a.minsize)")


generate(o, n) = o

function generate(a::Bencharg, n)
    Random.seed!(42)
    a.gen( n... )
end

generate(t::Tuple, n) = map(a -> generate(a, n), t)


smallest(o) = o

smallest(a::Bencharg) = generate(a, a.minsize)

smallest(t::Tuple) = map(smallest, t)

function tag(o)
    t = typeof(o)
    if hasmethod(size, (t,))
        return (type=t, size=size(o))
    end
    return t
end

tag(f::Function) = f

tag(a::Bencharg) = a.tag

tag(t::Tuple) = map(tag, t)


end # module

