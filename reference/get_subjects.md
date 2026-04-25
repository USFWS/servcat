# Get subject categories from a ServCat reference

Get subject categories from a ServCat reference

## Usage

``` r
get_subjects(reference_id, secure = FALSE, api_key = NULL)
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

A tibble of subject categories associated with the reference.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve subject categories for a public reference
get_subjects(140411)

# Retrieve subject categories using the secure API
get_subjects(
  reference_id = 140411,
  secure = TRUE
)
} # }
```
