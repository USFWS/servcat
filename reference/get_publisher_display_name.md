# Get ServCat publisher display name by reference type

Retrieves the display name for the `Publisher` field for a given ServCat
reference type.

## Usage

``` r
get_publisher_display_name(reference_type, secure = FALSE, api_key = NULL)
```

## Arguments

- reference_type:

  A single ServCat reference type, such as `"Brochure"`.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key.

## Value

A tibble with the publisher field display name.
