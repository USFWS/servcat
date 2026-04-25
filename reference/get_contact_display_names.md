# Get ServCat contact display names by reference type

Retrieves the display names for the `Contacts1`, `Contacts2`, and
`Contacts3` fields for a given ServCat reference type.

## Usage

``` r
get_contact_display_names(reference_type, secure = FALSE, api_key = NULL)
```

## Arguments

- reference_type:

  A single ServCat reference type, such as `"Brochure"`.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key.

## Value

A tibble with contact field display names.
