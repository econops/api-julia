using Test
using econops

@testset "Client Construction and Basic Functionality" begin
    @testset "Client Construction" begin
        # Test default constructor
        client = Client()
        @test client.use_cache == true
        @test haskey(client.headers, "Authorization")
        @test haskey(client.headers, "Content-Type")
        @test !isempty(client.token) #Should have a token (demo or from env)
        
        # Test with custom parameters
        client = Client(token="test_token", base_url="https://test.com", use_cache=false)
        @test client.token == "test_token"
        @test client.base_url == "https://test.com"
        @test client.use_cache == false
    end
    
    @testset "Environment Variable Handling" begin
        # Test with environment variable
        ENV["ECONOPS_TOKEN"] = "env_token"
        client = Client()
        @test client.token == "env_token"
        
        # Test that parameter overrides environment variable
        client = Client(token="param_token")
        @test client.token == "param_token"
        
        # Clean up
        delete!(ENV, "ECONOPS_TOKEN")
    end
    
    @testset "Error Handling" begin
        # Test error when no token is provided
        delete!(ENV, "ECONOPS_TOKEN")
        @test_throws ErrorException Client(token=nothing)
        
        # Restore demo token
        ENV["ECONOPS_TOKEN"] = "demo"
    end
end
