module MapReduce

import Bench.Args

import LinearAlgebra: tr, det, logdet, inv, isposdef

import DataStructures: counter

import Random

import Base.Threads: @threads, nthreads

counter(s::AbstractString) = DataStructures.counter((s,))

const fs  = [ exp, sqrt, tr, det, logdet, inv, isposdef, counter ]

const ops = [ (+), (*), max, merge ]

const benchargs = Args.Bencharg.([
                      n -> map(x -> Random.randstring('a':'d', 2), 1:n),
                      n -> map(x -> Random.randstring('a':'d', 4), 1:n),
                      n -> map(x -> Random.randstring('a':'d', 6), 1:n),
                      n -> Random.randperm(n),
                      n -> convert(Vector{Float16}, Random.randperm(n)),
                      n -> convert(Vector{Float32}, Random.randperm(n)),
                      n -> convert(Vector{Float64}, Random.randperm(n)),
                      n -> convert(Vector{BigInt}, Random.randperm(n)),
                      n -> convert(Vector{BigFloat}, Random.randperm(n)),
                      n -> map(x -> Random.randn(3  , 3  ), 1:n),
                      n -> map(x -> convert(Matrix{BigFloat}, Random.randn(3 , 3 )), 1:n),
                      n -> map(x -> Random.randn(42 , 42 ), 1:n),
                      n -> map(x -> convert(Matrix{BigFloat}, Random.randn(42 , 42 )), 1:n),
                      n -> map(x -> Random.randn(200, 200), 1:n),
                  ])

function threaded_mapreduce(f, op, x)
    @assert length(x) % nthreads() == 0
    results = zeros(eltype(x), nthreads())
    @threads for tid in 1:nthreads()
        # split work
        start = 1 + ((tid - 1) * length(x)) ÷ nthreads()
        stop = (tid * length(x)) ÷ nthreads()
        domain = start:stop
                
        results[tid] = mapreduce(f, op, view(x, domain))
    end
    foldl(op, results)
end

function atomic_mapreduce(f,op,x)
    results = zeros(eltype(x), nthreads())

    total = Threads.Atomic{Float64}(0.0)
    @threads for tid in 1:nthreads()
        # split work
        start = 1 + ((tid - 1) * length(x)) ÷ nthreads()
        stop = (tid * length(x)) ÷ nthreads()
        domain = (start+1):stop
        
        acc = f(x[start])
        for j in domain
            @inbounds acc = op(acc, f(x[j]))
        end

        Threads.atomic_add!(total, acc)
    end

    total.value
end

function naive_simd(f, op, x::AbstractArray{T}) where {T}
   s = f(x[1])
   @simd for xᵢ ∈ view(x, 2:length(x))
       s = op(s, f(xᵢ))
   end
   s
end

const mrs = [ mapreduce, threaded_mapreduce, atomic_mapreduce, naive_simd ]

end # module
