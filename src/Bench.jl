module Bench

include("args.jl")
#
import Bench.Args: generate, smallest, tag

import BenchmarkTools: BenchmarkGroup, @benchmarkable

function valid(f, args)
    try
        f(args...)
        return true
    catch
        return false
    end
end

function push!(suite, ns, f, args)
    key = Tuple( (f, tag.(args)...) )
    suite[key] = BenchmarkGroup(collect(key))
    for n in ns
        arg = generate(n, args)
        suite[key][n] = @benchmarkable $f( $arg... )
    end
end

function productsuite(ns, fs, arglist...)
    suite = BenchmarkGroup()
    for f in fs
        for args in Iterators.product(arglist...)
            push!(suite, ns, f, args)
        end
    end
    return suite
end

end # module
