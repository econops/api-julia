using Test
using econops

@testset "Cache Functionality" begin
    @testset "Cache Directory" begin
        cache_dir = get_cache_dir()
        @test isdir(cache_dir)
        @test occursin(".econops", cache_dir)
    end
    
    @testset "Cache Operations" begin
        client = Client(use_cache=true)
        
        # Test cache info
        info = get_cache_info(client)
        @test haskey(info, "cache_directory")
        @test haskey(info, "cached_requests")
        @test haskey(info, "cache_size_bytes")
        
        # Test clear cache
        clear_cache(client)
        info_after = get_cache_info(client)
        @test info_after["cached_requests"] == 0
    end
    
    @testset "Cache with Disabled Caching" begin
        client = Client(use_cache=false)
        
        # Test cache info with disabled caching
        info = get_cache_info(client)
        @test haskey(info, "cache_directory")
        @test haskey(info, "cached_requests")
        @test haskey(info, "cache_size_bytes")
        
        # Clear cache should still work
        clear_cache(client)
        info_after = get_cache_info(client)
        @test info_after["cached_requests"] == 0
    end
end
