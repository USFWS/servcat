# Get valid ServCat date precision choices

Retrieves the fixed list of DatePrecision choices used for issued dates
and content begin/end dates.

## Usage

``` r
get_date_precisions(secure = FALSE, api_key = NULL)
```

## Arguments

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key.

## Value

A tibble with date precision choices.
