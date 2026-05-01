# Get ServCat reference summaries by ID

Get ServCat reference summaries by ID

## Usage

``` r
get_reference_summaries(reference_ids, secure = FALSE, api_key = NULL)
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

A tibble containing summary information about each reference.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve summary fields for one reference
get_reference_summaries(140411)

# Retrieve summary fields for multiple references
get_reference_summaries(c(140411, 140412))

# Long vectors are automatically requested in chunks
get_reference_summaries(c(140411, 140412, 140413))

# Use the secure API
get_reference_summaries(
  reference_ids = 140411,
  secure = TRUE
)
} # }
```
