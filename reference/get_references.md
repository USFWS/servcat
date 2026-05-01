# Get ServCat references by ID

Get ServCat references by ID

## Usage

``` r
get_references(reference_ids, secure = FALSE, api_key = NULL)
```

## Arguments

- reference_ids:

  Numeric vector of ServCat reference IDs.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A named list containing detailed information about each reference. Field
names returned by the API are preserved.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve detailed information for one reference
get_references(140411)

# Retrieve detailed information for multiple references
get_references(c(140411, 140412))

# Use the secure API
get_references(
  reference_ids = 140411,
  secure = TRUE
)
} # }
```
