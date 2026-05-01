# List valid ServCat subject categories

Retrieves the fixed list of Subject Categories used on the Keywords and
Category tab in ServCat.

## Usage

``` r
list_subject_categories(secure = FALSE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble with subject category choices.

## Examples

``` r
if (FALSE) { # \dontrun{
# List public subject category choices
list_subject_categories()

# List subject category choices from the secure API
list_subject_categories(secure = TRUE)
} # }
```
