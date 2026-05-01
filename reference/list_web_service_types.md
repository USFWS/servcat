# List valid ServCat web service types

Retrieves the fixed list of Web Service, or Linked Resource, types used
by ServCat.

## Usage

``` r
list_web_service_types(secure = FALSE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble with web service type choices.

## Examples

``` r
if (FALSE) { # \dontrun{
# List public web service type choices
list_web_service_types()

# List web service type choices from the secure API
list_web_service_types(secure = TRUE)
} # }
```
