using econops
using JSON3

println("=== Testing Econops PCA Example ===\n")

# Initialize client
println("1. Initializing client...")
client = Client(token="demo")
println("   ✓ Client initialized with base URL: $(client.base_url)\n")

# Test PCA computation
println("2. Making a PCA computation request...")
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
    println("   ✓ PCA response status: $(response.status)")
    
    if response.status == 200
        result = JSON3.read(response.body)
        println("   ✓ PCA result received:")
        println("     - Response keys: $(keys(result))")
        if haskey(result, "components")
            println("     - Components shape: $(size(result["components"]))")
        end
        if haskey(result, "explained_variance")
            println("     - Explained variance: $(result["explained_variance"])")
        end
    else
        println("   ✗ Error response: $(response.body)")
    end
    
catch e
    println("   ✗ Error: $e")
    println("   Stack trace: $(stacktrace())")
end
println()

println("=== Test completed ===")

