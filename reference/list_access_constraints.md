# List valid ServCat access constraint text

Retrieves the fixed list of access constraint text used when setting
permissions and constraints for a ServCat reference.

## Usage

``` r
list_access_constraints(secure = FALSE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble with access constraint metadata.

## Examples

``` r
if (FALSE) { # \dontrun{
# List public access constraint choices
list_access_constraints()

# List access constraint choices from the secure API
list_access_constraints(secure = TRUE)
} # }
```
