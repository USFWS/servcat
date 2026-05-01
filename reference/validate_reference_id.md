# Validate a ServCat reference ID

Validate a ServCat reference ID

## Usage

``` r
validate_reference_id(
  reference_id,
  multiple_ok = FALSE,
  arg = rlang::caller_arg(reference_id),
  call = rlang::caller_env()
)
```

## Arguments

- reference_id:

  ServCat reference ID or IDs.

- multiple_ok:

  Logical. Are multiple IDs allowed?

- arg:

  Used to generate helpful error messages.

- call:

  Calling environment.

## Value

`NULL`, invisibly.
