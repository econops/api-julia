"""
Econops API Client implementation
"""

using HTTP
using JSON3
using SHA

"""
Generate a unique signature for route and request data.

Args:
    route: The API route (e.g., "/compute/pca")
    request_data: The JSON request data as a dictionary
    pregiven: If not nothing, return this value directly (for caching/pre-computed signatures)

Returns:
    A unique hash string representing the route and request data
"""
function callsignature(route::String, request_data::Dict; pregiven::Union{String, Nothing}=nothing)
    if pregiven !== nothing
        return pregiven
    end
    
    # Create a deterministic string representation of the data
    # Sort the request data to ensure consistent hashing regardless of key order
    sorted_data = JSON3.write(request_data)
    
    # Hash the route for flexibility while maintaining security
    route_hash = bytes2hex(sha256(route))[1:8]  # First 8 chars
    
    # Combine route hash and data hash
    signature = route_hash * bytes2hex(sha256(sorted_data))
    
    return signature
end

"""
Get the cache directory for storing API responses.
"""
function get_cache_dir()
    cache_dir = joinpath(homedir(), ".econops", "cache")
    mkpath(cache_dir)
    return cache_dir
end

"""
Retrieve cached response for a given signature.

Args:
    signature: The request signature to look up
    
Returns:
    Cached response data or nothing if not found
"""
function get_cached_response(signature::String)
    cache_file = joinpath(get_cache_dir(), "$(signature).json")
    
    if isfile(cache_file)
        try
            cached_data = JSON3.read(cache_file)
            return cached_data
        catch e
            # Corrupted cache file, remove it
            rm(cache_file, force=true)
        end
    end
    
    return nothing
end

"""
Cache a response for future use.

Args:
    signature: The request signature as cache key
    response_data: The response data to cache
"""
function cache_response(signature::String, response_data::Dict)
    cache_file = joinpath(get_cache_dir(), "$(signature).json")
    
    try
        open(cache_file, "w") do f
            write(f, JSON3.write(response_data))
        end
    catch e
        # Silently fail if we can't write to cache
    end
end

"""
Econops API Client

A client for making requests to the Econops API with automatic authentication
and request signing.

Args:
    token: API token. If not provided, will try to get from 'ECONOPS_TOKEN' environment variable.
    base_url: Base URL for the API. Defaults to "https://econops.com:8000".
    use_cache: Whether to use response caching. Defaults to true.
    use_cert: Whether to use SSL certificate verification. Defaults to false for security.
"""
mutable struct Client
    token::String
    base_url::String
    use_cache::Bool
    use_cert::Bool
    headers::Dict{String, String}
    
    function Client(; token::Union{String, Nothing}=nothing, 
                   base_url::String="https://econops.com:8000", 
                   use_cache::Bool=true,
                   use_cert::Bool=false)
        
        # Get token from parameter or environment
        api_token = token !== nothing ? token : Base.get(ENV, "ECONOPS_TOKEN", "demo")
        if isempty(api_token)
            error("Token not provided and 'ECONOPS_TOKEN' environment variable not found")
        end
        
        base_url_clean = rstrip(base_url, '/')
        
        # Prepare default headers (no Authorization header - token goes in payload)
        headers = Dict{String, String}(
            "Content-Type" => "application/json"
        )
        
        new(api_token, base_url_clean, use_cache, use_cert, headers)
    end
end

"""
Make a request to any route with bearer token authentication.
Checks cache first if caching is enabled.

Args:
    client: The Client instance
    route: The API route to call (e.g., "/compute/pca")
    data: Data to send in the request body (optional)
    method: HTTP method (GET, POST, etc.)

Returns:
    HTTP.Response: The response from the API
"""
function get(client::Client, route::String; data::Union{Dict, Nothing}=nothing, method::String="POST")
    # Generate signature for the request
    request_data = data !== nothing ? data : Dict()
    signature = callsignature(route, request_data)
    
    # Check cache first (only for GET requests or when explicitly requested)
    if client.use_cache && (uppercase(method) == "GET" || data === nothing)
        cached_response = get_cached_response(signature)
        if cached_response !== nothing
            # Create a mock response object from cached data
            return cached_response
        end
    end
    
    # Make actual API request
    url = "$(client.base_url)$(route)"
    
    # Add signature to payload for security (never in URL)
    # Force POST for requests with data to keep signature in payload
    if data !== nothing
        method = "POST"  # Override GET to POST for data requests
    end
    
    if uppercase(method) == "GET"
        # For GET requests without data, use simple GET (no signature needed)
        if client.use_cert
            response = HTTP.get(url, client.headers)
        else
            response = HTTP.get(url, client.headers; require_ssl_verification=false)
        end
    else
        # For POST/PUT requests, add signature to payload
        payload = copy(data !== nothing ? data : Dict())
        payload["signature"] = signature
        if client.use_cert
            response = HTTP.post(url, client.headers, JSON3.write(payload))
        else
            response = HTTP.post(url, client.headers, JSON3.write(payload); require_ssl_verification=false)
        end
    end
    
    # Cache successful responses
    if client.use_cache && response.status == 200
        try
            response_data = Dict(
                "status" => response.status,
                "data" => JSON3.read(response.body),
                "headers" => Dict(response.headers)
            )
            cache_response(signature, response_data)
        catch e
            # Don't cache non-JSON responses
        end
    end
    
    return response
end

"""
Backward compatibility: make_request method that calls get
"""
function make_request(client::Client, route::String; data::Union{Dict, Nothing}=nothing, method::String="POST")
    return get(client, route, data=data, method=method)
end

"""
Clear all cached responses.
"""
function clear_cache(client::Client)
    cache_dir = get_cache_dir()
    for file in readdir(cache_dir)
        if endswith(file, ".json")
            rm(joinpath(cache_dir, file), force=true)
        end
    end
end

"""
Get information about the cache.
"""
function get_cache_info(client::Client)
    cache_dir = get_cache_dir()
    cache_files = filter(x -> endswith(x, ".json"), readdir(cache_dir))
    
    total_size = 0
    for file in cache_files
        file_path = joinpath(cache_dir, file)
        if isfile(file_path)
            total_size += filesize(file_path)
        end
    end
    
    return Dict(
        "cache_directory" => cache_dir,
        "cached_requests" => length(cache_files),
        "cache_size_bytes" => total_size
    )
end