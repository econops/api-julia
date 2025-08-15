using Test
using econops

@testset "Signature Generation" begin
    @testset "Signature Generation" begin
        route = "/compute/pca"
        data = Dict("data" => [[1, 2, 3], [4, 5, 6]], "n_components" => 2)
        
        # Test that signature is deterministic
        sig1 = callsignature(route, data)
        sig2 = callsignature(route, data)
        @test sig1 == sig2
        
        # Test that different data produces different signatures
        data2 = Dict("data" => [[1, 2, 3], [4, 5, 7]], "n_components" => 2)
        sig3 = callsignature(route, data2)
        @test sig1 != sig3
        
        # Test pregiven parameter
        pregiven = "test_signature"
        sig4 = callsignature(route, data, pregiven=pregiven)
        @test sig4 == pregiven
        
        # Test that different routes produce different signatures
        route2 = "/compute/svd"
        sig5 = callsignature(route2, data)
        @test sig1 != sig5
    end
end
