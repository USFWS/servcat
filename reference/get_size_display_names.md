# Get ServCat size display names by reference type

Retrieves the display names for the `Size1`, `Size2`, and `Size3` fields
for a given ServCat reference type.

## Usage

``` r
get_size_display_names(reference_type, secure = FALSE, api_key = NULL)
```

## Arguments

- reference_type:

  A single ServCat reference type, such as `"Brochure"`.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key.

## Value

A tibble with size field display names.
