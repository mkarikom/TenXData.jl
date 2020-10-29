module TenX

using CodecZlib,TranscodingStreams
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
        #fh = GZip.open(countFn)
        fh = GzipDecompressorStream(open(countFn))
        #M = TenX.mmread(fh)
        M = TenX.mmread(fh)
    else
        M = mmread(countFn)
    end
    gh = GzipDecompressorStream(open(geneFn))
    G = map(r->r[1],CSV.File(gh,header=0))
    bh = GzipDecompressorStream(open(barcodeFn))
    B = map(r->r[1],CSV.File(bh,header=0))
    df = rename!(DataFrame(M),B)
    insertcols!(df,1,"gene"=>G)
    df
end

# process files with standard names
function loadFolder(dirPath::String)
    fm = Dict(:gn=>"features.tsv.gz",
              :bc=>"barcodes.tsv.gz",
              :cnt=>"matrix.mtx.gz")
     df = TenX.loadData(string(dirPath,"/",get(fm,:cnt,"")),
                        string(dirPath,"/",get(fm,:bc,"")),
                        string(dirPath,"/",get(fm,:gn,"")))
end
end
