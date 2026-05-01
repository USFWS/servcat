# Get references in a saved collection

Retrieves the references belonging to a ServCat Saved Collection using
the composite endpoint, which returns additional nested detail such as
linked resources and associated units.

## Usage

``` r
get_collection_references(collection_id, secure = FALSE, api_key = NULL)
```

## Arguments

- collection_id:

  A single ServCat Saved Collection ID.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key. If omitted, the package API-key helper is
  used for secure requests.

## Value

A tibble of composite reference records. Nested fields such as
`linkedResources` and `units` are returned as list-columns.

## Examples

``` r
if (FALSE) { # \dontrun{
refs <- get_collection_references(1397)

refs

# View linked resources for the first reference
refs$linkedResources[[1]]

# View associated units for the first reference
refs$units[[1]]
} # }
```
