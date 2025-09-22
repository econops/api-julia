"""
Econops API Client

A Julia client for the Econops API providing statistical and data science for economics and finance.
"""

module econops

using HTTP
using JSON3
using SHA

export Client, get, make_request, clear_cache, get_cache_info, callsignature, get_cache_dir

include("client.jl")
include("cli.jl")

# Create a default client for convenience (with certificate verification disabled by default)
const DEFAULT_CLIENT = Client(use_cert=false)

"""
Convenience function to make API requests without creating a client instance.
Uses the default client with demo token.

Args:
    route: The API route to call (e.g., "/compute/pca")
    data: Data to send in the request body (optional)
    method: HTTP method (GET, POST, etc.)

Returns:
    HTTP.Response: The response from the API
"""
function get(route::String; data::Union{Dict, Nothing}=nothing, method::String="POST")
    return get(DEFAULT_CLIENT, route, data=data, method=method)
end

end # module

