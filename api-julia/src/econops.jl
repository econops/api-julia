"""
Econops API Client

A Julia client for the Econops API providing statistical and data science for economics and finance.
"""

module econops

using HTTP
using JSON3
using SHA

export Client, get, clear_cache, get_cache_info, callsignature, get_cache_dir

include("client.jl")
include("cli.jl")

end # module

