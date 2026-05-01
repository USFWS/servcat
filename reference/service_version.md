# Get the current ServCat service version

Retrieves the current ServCat service version from the service metadata
endpoint.

## Usage

``` r
service_version(secure = FALSE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A length-1 character vector with the current ServCat service version.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve the public ServCat service version
service_version()

# Retrieve the secure ServCat service version
service_version(secure = TRUE)
} # }
```
