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
        gh = GzipDecompressorStream(open(geneFn))
        G = map(r->r[1],CSV.File(gh,header=0))
        bh = GzipDecompressorStream(open(barcodeFn))
        B = map(r->r[1],CSV.File(bh,header=0))
    else
        M = mmread(countFn)
        G = map(r->r[1],CSV.File(geneFn,header=0))
        B = map(r->r[1],CSV.File(barcodeFn,header=0))
    end
    df = rename!(DataFrame(M),B)
    insertcols!(df,1,"gene"=>G)
    df
end

# process files with standard names
function loadFolder(dirPath::String)
    fm = Dict(:gn1=>"features.tsv.gz",
              :gn2=>"features.tsv",
              :gn3=>"genes.tsv.gz",
              :gn4=>"genes.tsv",
              :bc=>"barcodes.tsv.gz",
              :bc2=>"barcodes.tsv",
              :cnt=>"matrix.mtx.gz",
              :cnt2=>"matrix.mtx")

    if isfile(joinpath(dirPath,get(fm,:gn1,"")))
        df = TenX.loadData(joinpath(dirPath,get(fm,:cnt,"")),
                           joinpath(dirPath,get(fm,:bc,"")),
                           joinpath(dirPath,get(fm,:gn1,"")))
    elseif isfile(joinpath(dirPath,get(fm,:gn2,"")))
        df = TenX.loadData(joinpath(dirPath,get(fm,:cnt2,"")),
                           joinpath(dirPath,get(fm,:bc2,"")),
                           joinpath(dirPath,get(fm,:gn2,"")))
    elseif isfile(joinpath(dirPath,get(fm,:gn3,"")))
        df = TenX.loadData(joinpath(dirPath,get(fm,:cnt,"")),
                           joinpath(dirPath,get(fm,:bc,"")),
                           joinpath(dirPath,get(fm,:gn3,"")))
    elseif isfile(joinpath(dirPath,get(fm,:gn4,"")))
        df = TenX.loadData(joinpath(dirPath,get(fm,:cnt2,"")),
                           joinpath(dirPath,get(fm,:bc2,"")),
                           joinpath(dirPath,get(fm,:gn4,"")))
    end
    df
end
end
