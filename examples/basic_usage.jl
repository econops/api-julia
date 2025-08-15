"""
Basic usage example for the EconOps Julia API client.
"""

using econops
using JSON3

println("=== Econops Julia API Client Example ===\n")

# Initialize client
println("1. Initializing client...")
client = Client(token="demo")  # Using demo token for example
println("   ✓ Client initialized with base URL: $(client.base_url)\n")

# Example 1: Simple GET request
println("2. Making a simple GET request...")
try
    response = get(client, "/status", method="GET")
    println("   ✓ Status response: $(response.status)")
    if response.status == 200
        result = JSON3.read(response.body)
        println("   ✓ Response data: $(JSON3.pretty(result))")
    end
catch e
    println("   ✗ Error: $e")
end
println()

# Example 2: PCA computation
println("3. Making a PCA computation request...")
try
    # Sample data for PCA
    data = [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0],
        [7.0, 8.0, 9.0],
        [10.0, 11.0, 12.0]
    ]
    
    request_data = Dict(
        "data" => data,
        "n_components" => 2
    )
    
    response = get(client, "/compute/pca", data=request_data)
    println("   ✓ PCA response: $(response.status)")
    if response.status == 200
        result = JSON3.read(response.body)
        println("   ✓ PCA result: $(JSON3.pretty(result))")
    end
catch e
    println("   ✗ Error: $e")
end
println()

# Example 3: Cache demonstration
println("4. Demonstrating caching...")
try
    # First request (should hit API)
    println("   Making first request...")
    response1 = get(client, "/compute/pca", data=Dict("data" => [[1, 2], [3, 4]], "n_components" => 1))
    println("   ✓ First request completed")
    
    # Second request with same data (should use cache)
    println("   Making second request with same data...")
    response2 = get(client, "/compute/pca", data=Dict("data" => [[1, 2], [3, 4]], "n_components" => 1))
    println("   ✓ Second request completed")
    
    # Check cache info
    cache_info = get_cache_info(client)
    println("   ✓ Cache info: $(cache_info)")
    
catch e
    println("   ✗ Error: $e")
end
println()

# Example 4: Cache management
println("5. Cache management...")
try
    # Clear cache
    clear_cache(client)
    println("   ✓ Cache cleared")
    
    # Check cache info after clearing
    cache_info = get_cache_info(client)
    println("   ✓ Cache info after clearing: $(cache_info)")
    
catch e
    println("   ✗ Error: $e")
end
println()

println("=== Example completed ===")

