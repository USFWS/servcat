# List valid ServCat reference type groups

Retrieves the fixed list of Reference Type Groups used as an Advanced
Search option in ServCat.

## Usage

``` r
list_reference_type_groups(secure = FALSE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble with reference type group choices.

## Examples

``` r
if (FALSE) { # \dontrun{
# List public reference type groups
list_reference_type_groups()

# List reference type groups from the secure API
list_reference_type_groups(secure = TRUE)
} # }
```
