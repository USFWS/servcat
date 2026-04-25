# Get keywords from a ServCat reference

Get keywords from a ServCat reference

## Usage

``` r
get_keywords(reference_id, secure = FALSE, api_key = NULL)
```

## Arguments

- reference_id:

  A single ServCat reference ID.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A character vector of keywords.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve keywords for a public reference
get_keywords(140411)

# Retrieve keywords using the secure API
get_keywords(
  reference_id = 140411,
  secure = TRUE
)
} # }
```
