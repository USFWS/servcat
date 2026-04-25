# Get valid ServCat access constraint text

Retrieves the fixed list of access constraint text used when setting
permissions and constraints for a ServCat reference.

## Usage

``` r
get_access_constraints(secure = FALSE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key.

## Value

A tibble with access constraint metadata.
