# Clean an error message for use in returned data

Removes ANSI styling and collapses whitespace so condition messages can
be stored cleanly in tibble columns.

## Usage

``` r
clean_error_message(x)
```

## Arguments

- x:

  A condition object or character string.

## Value

A clean character scalar.
