# Econops API Julia Client

A Julia client for the Econops API providing statistical and data science capabilities for economics and finance.

## Installation

### From Julia REPL
```julia
using Pkg
Pkg.add("https://github.com/econops/api-julia.git")
```

### Development installation
```bash
git clone https://github.com/econops/api-julia.git
cd api-julia
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

## Quick Start

```julia
using econops

# Initialize client with your API token
client = Client(token="your_api_token")

# Make a request to the API
response = get(client, "/compute/pca", data=Dict(
    "data" => [[1, 2, 3], [4, 5, 6]],
    "n_components" => 2
))

println(JSON3.read(response.body))
```

## Environment Variables

You can set your API token as an environment variable:

```bash
export ECONOPS_TOKEN="your_api_token"
```

Then use the client without passing the token:

```julia
using econops
client = Client()  # Will use ECONOPS_TOKEN environment variable

## API Reference

### Client Type

The main `Client` type provides methods to interact with the Econops API.

#### Constructor

```julia
Client(; token=nothing, base_url="https://econops.com:8000", use_cache=true)
```

- `token` (String, optional): Your API token. If not provided, will try to get from `ECONOPS_TOKEN` environment variable.
- `base_url` (String): Base URL for the API. Defaults to "https://econops.com:8000".
- `use_cache` (Bool): Whether to use response caching. Defaults to true.

#### Methods

##### get(client, route; data=nothing, method="POST")

Make a request to any API route with automatic authentication and request signing.

- `client`: The Client instance
- `route` (String): The API route to call (e.g., "/compute/pca")
- `data` (Dict, optional): Data to send in the request body
- `method` (String): HTTP method (GET, POST, etc.)

**Security:** Request signatures are included in the payload (not headers) for enhanced security.

Returns: `HTTP.Response` object

##### clear_cache(client)

Clear all cached responses.

##### get_cache_info(client)

Get information about the cache.

Returns: Dictionary with cache statistics

## Examples

### Principal Component Analysis
```julia
using econops

client = Client(token="your_token")

# Perform PCA on your data
response = get(client, "/compute/pca", data=Dict(
    "data" => your_data_matrix,
    "n_components" => 3
))

result = JSON3.read(response.body)
```

### Time Series Analysis
```julia
response = get(client, "/compute/timeseries", data=Dict(
    "data" => time_series_data,
    "method" => "arima"
))
```

### Caching

The client automatically caches responses to avoid redundant API calls:

```julia
# First call hits the API
response1 = get(client, "/compute/pca", data=Dict("data" => [[1,2,3]]))

# Second call with same data returns cached result (even if route changes)
response2 = get(client, "/api/v2/pca", data=Dict("data" => [[1,2,3]]))  # Same cache hit!

# Cache management
clear_cache(client)  # Clear all cached responses
info = get_cache_info(client)  # Get cache statistics
println(info)
# Dict{String, Any}("cache_directory" => "/home/user/.econops/cache", "cached_requests" => 5, "cache_size_bytes" => 1024)
```

**Note:** Caching is based on request data only, not the route. This allows for API refactoring without breaking cache compatibility.

## Command Line Interface

The package also provides a command-line interface:

```bash
# Make a PCA request
  julia -e 'using econops; main()' -- --route /compute/pca --data '{"data": [[1,2,3], [4,5,6]], "n_components": 2}'
  
  # Make a GET request
  julia -e 'using econops; main()' -- --route /status --method GET
  
  # Pretty print response
  julia -e 'using econops; main()' -- --route /compute/pca --data '{"data": [[1,2,3]]}' --pretty
```

## Development

### Running Tests
```julia
using Pkg
Pkg.test("econops")
```

### Code Formatting
```julia
using JuliaFormatter
format(".")
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Support

- Documentation: https://econops.com/docs/julia
- Issues: https://github.com/econops/api-julia/issues
- Email: info@econops.com

