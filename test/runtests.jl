using MallocArrays
using Test
using Aqua

@testset "MallocArrays.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(MallocArrays)
    end
    # Write your tests here.
end
