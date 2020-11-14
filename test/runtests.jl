using TenX,CSV
using Test

dn = joinpath(@__DIR__,"data")
gzd = joinpath(dn,"gz")
tsd = joinpath(dn,"tsv")
checkfn = joinpath(dn,"check.csv")

@testset "TenX.jl" begin
	gdf = TenX.loadFolder(gzd)

	check = CSV.read(checkfn,DataFrame)
    @test Matrix(check) == Matrix(gdf[:,2:end])

	tdf = TenX.loadFolder(tsd)
	@test Matrix(check) == Matrix(tdf[:,2:end])
end
