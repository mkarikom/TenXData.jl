"""
### mmread(filename, infoonly::Bool=false, retcoord::Bool=false)
Read the contents of the Matrix Market file 'filename' into a matrix,
which will be either sparse or dense, depending on the Matrix Market format
indicated by 'coordinate' (coordinate sparse storage), or 'array' (dense
array storage).
If infoonly is true (default: false), only information on the size and
structure is returned from reading the header. The actual data for the
matrix elements are not parsed.
If retcoord is true (default: false), the rows, column and value vectors
are returned, if it is a sparse matrix, along with the header information.
"""
function mmread(mmstream::TranscodingStream, infoonly::Bool=false, retcoord::Bool=false)
    # Read first line
    firstline = chomp(readline(mmstream))
    tokens = split(firstline)
    if length(tokens) != 5
        throw(ParseError(string("Not enough words on first line: ", firstline)))
    end
    if tokens[1] != "%%MatrixMarket"
        throw(ParseError(string("Expected start of header `%%MatrixMarket`, got `$(tokens[1])`")))
    end
    (head1, rep, field, symm) = map(lowercase, tokens[2:5])
    if head1 != "matrix"
        throw(ParseError("Unknown MatrixMarket data type: $head1 (only \"matrix\" is supported)"))
    end

    eltype = field == "real" ? Float64 :
             field == "complex" ? ComplexF64 :
             field == "integer" ? Int64 :
             field == "pattern" ? Bool :
             throw(ParseError("Unsupported field $field (only real and complex are supported)"))

    symlabel = symm == "general" ? identity :
               symm == "symmetric" ? symmetric! :
               symm == "hermitian" ? hermitian! :
               symm == "skew-symmetric" ? skewsymmetric! :
               throw(ParseError("Unknown matrix symmetry: $symm (only general, symmetric, skew-symmetric and hermitian are supported)"))

    # Skip all comments and empty lines
    ll   = readline(mmstream)
    while length(chomp(ll))==0 || (length(ll) > 0 && ll[1] == '%')
        ll = readline(mmstream)
    end
    # Read matrix dimensions (and number of entries) from first non-comment line
    dd = map(_parseint, split(ll))
    if length(dd) < (rep == "coordinate" ? 3 : 2)
        throw(ParseError(string("Could not read in matrix dimensions from line: ", ll)))
    end
    rows = dd[1]
    cols = dd[2]
    entries = (rep == "coordinate") ? dd[3] : (rows * cols)
    infoonly && return (rows, cols, entries, rep, field, symm)

    rep == "coordinate" ||
        return symlabel(reshape([parse(Float64, readline(mmstream)) for i in 1:entries],
                                (rows,cols)))

    rr = Vector{Int}(undef, entries)
    cc = Vector{Int}(undef, entries)
    xx = Vector{eltype}(undef, entries)
    for i in 1:entries
        line = readline(mmstream)
        splits = find_splits(line, eltype == ComplexF64 ? 3 : (eltype == Bool ? 1 : 2))
        rr[i] = _parseint(line[1:splits[1]])
        cc[i] = _parseint(eltype == Bool
                          ? line[splits[1]:end]
                          : line[splits[1]:splits[2]])
        if eltype == ComplexF64
            real = parse(Float64, line[splits[2]:splits[3]])
            imag = parse(Float64, line[splits[3]:length(line)])
            xx[i] = ComplexF64(real, imag)
        elseif eltype == Bool
            xx[i] = true
        else
            xx[i] = parse(eltype, line[splits[2]:length(line)])
        end
    end
    (retcoord
     ? (rr, cc, xx, rows, cols, entries, rep, field, symm)
     : symlabel(sparse(rr, cc, xx, rows, cols)))
end
