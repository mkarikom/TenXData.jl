module TenX

using GZip
using DataFrames,CSV
using SparseArrays # needed for mmread
using Compat.SparseArrays # needed for mmread
using Compat.LinearAlgebra # needed for mmread
using MatrixMarket: _parseint,find_splits,skewsymmetric!,symmetric!,hermitian! # needed for mmread

import MatrixMarket.mmread

include("MM.jl")

function loadData(countFn::String,geneFn::String,barcodeFn::String)
    extn = split(countFn,".")[end]
    if extn == "gz" || extn == "gzip"
        fh = GZip.open(countFn)
        M = TenX.mmread(fh)
        G = map(r->r[1],CSV.File(GZip.open(geneFn)))
        B = map(r->r[1],CSV.File(GZip.open(barcodeFn)))

        df = DataFrame(M)
    else
    end
end
end
