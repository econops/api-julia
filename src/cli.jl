"""
Command-line interface for the Econops API client.
"""

using JSON3

"""
Main CLI entry point for the Econops API client.
"""
function main()
    # Simple CLI that reads from environment variables or uses defaults
    # This is a simplified version without ArgParse dependency
    
    # Get route from environment or use default
    route = get(ENV, "ECONOPS_ROUTE", "/status")
    
    # Get method from environment or use default
    method = get(ENV, "ECONOPS_METHOD", "GET")
    
    # Get data from environment (optional)
    data_str = get(ENV, "ECONOPS_DATA", nothing)
    
    # Get base URL from environment or use default
    base_url = get(ENV, "ECONOPS_BASE_URL", "https://api.econops.com")
    
    # Get token from environment
    token = get(ENV, "ECONOPS_TOKEN", "demo")
    
    # Parse data if provided
    data = nothing
    if data_str !== nothing
        try
            data = JSON3.read(data_str)
        catch e
            println(stderr, "Error parsing JSON data: $e")
            return
        end
    end
    
    try
        # Initialize client
        client = Client(
            token = token,
            base_url = base_url,
            use_cache = true
        )
        
        # Make request
        response = get(client, route, data=data, method=method)
        
        # Print response
        if haskey(response, "status") ? response["status"] == 200 : response.status == 200
            try
                if haskey(response, "data")
                    # This is a cached response
                    result = response["data"]
                else
                    # This is a real HTTP response
                    result = JSON3.read(response.body)
                end
                
                println(JSON3.pretty(result))
            catch e
                println(response.body)
            end
        else
            println(stderr, "Error $(response.status): $(response.body)")
            return
        end
        
    catch e
        println(stderr, "Error: $e")
        return
    end
end

# Export the main function
export main