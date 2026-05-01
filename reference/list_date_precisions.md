# List valid ServCat date precision choices

Retrieves the fixed list of DatePrecision choices used for issued dates
and content begin/end dates.

## Usage

``` r
list_date_precisions(secure = FALSE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble with date precision choices.

## Examples

``` r
if (FALSE) { # \dontrun{
# List public date precision choices
list_date_precisions()

# List date precision choices from the secure API
list_date_precisions(secure = TRUE)
} # }
```
