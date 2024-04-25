using MallocArrays
using Test
using Aqua

@testset "MallocArrays.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(MallocArrays, deps_compat=false)
        Aqua.test_deps_compat(MallocArrays, check_extras=false)
    end

    @testset "Basics" begin
        x = malloc(Int, 10)
        @test x isa AbstractVector{Int}
        @test x isa MallocArray

        x .= 1:10
        @test x == 1:10

        @test_throws BoundsError x[11]
        @test_throws BoundsError x[0]
        @test_throws BoundsError x[0] = 0
        @test_throws BoundsError x[11] = 0

        @test free(x) === nothing

        y = malloc(Complex{Float64}, 4, 10)
        @test length(y) == 40
        @test size(y) == (4, 10)
        @test y isa AbstractMatrix{Complex{Float64}}
        @test y isa MallocArray

        fill!(y, im)
        @test all(z -> z === 1.0im, y)
        @test count(!iszero, y) == 40
        y[4, 10] = 0
        @test y[40] == y[4, 10] == 0
        @test_throws BoundsError y[41]
        @test_throws BoundsError y[10, 4]

        @test free(y) === nothing

        @test_throws ArgumentError malloc(Vector{Int}, 10)
    end

    function f(x, y)
        z = malloc(Int, x)
        z .= y
        res = sum(z)
        free(z)
        res
    end
    @testset "Allocations" begin
        @test f(10, 1:10) == 55
        @test 0 == @allocated f(10, 1:10)
    end
end
