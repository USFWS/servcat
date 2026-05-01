# Remove NULL values from a nested list

Recursively removes `NULL` values from a list before sending it as a
JSON request body. Empty child lists are retained.

## Usage

``` r
compact_null_values(x)
```

## Arguments

- x:

  A list or other object.

## Value

`x` with `NULL` list elements removed.
