# Execute an Advanced Search

Executes a ServCat Advanced Search using a POST request. Search criteria
are posted in the request body, while paging and sorting parameters are
sent as URI query parameters.

## Usage

``` r
search_references_advanced(
  criteria,
  top = 25,
  page = 1,
  orderby = NULL,
  sort = NULL,
  composite = FALSE,
  secure = FALSE,
  api_key = NULL
)
```

## Arguments

- criteria:

  A named list of Advanced Search criteria. Supported top-level fields
  include:

  `quickSearch`

  :   A character string to search using ServCat Quick Search. If
      supplied, Quick Search is the primary source of results, and other
      filters are applied to those results.

  `visibility`

  :   Optional visibility filter. Use `"public"` to return only public
      records, `"internal"` to return only internal records, or `NULL`
      to return both when available. Non-secure services can return only
      public records.

  `legacy`

  :   Optional legacy-status filter. Use `"excludelegacy"` to return
      only non-legacy records, `"onlylegacy"` to return only legacy
      records, or `NULL` to ignore legacy status.

  `version`

  :   Optional version filter. Use `"all"` to include all versions of
      versioned records, or `NULL` to return only the most recent
      version.

  `regions`

  :   A list of Region filters. Each entry may include `order`,
      `logicOperator`, and `unitCode`.

  `units`

  :   A list of Unit filters. Each entry may include `order`,
      `logicOperator`, `unitCode`, `linked`, and `approved`.

  `textFields`

  :   A list of text-field filters. Each entry may include `order`,
      `logicOperator`, `fieldName`, and `searchText`. Valid `fieldName`
      values include `"Abstract"`, `"Notes"`, `"TableOfContent"`,
      `"ContactName"`, `"Publisher"`, `"Keyword"`,
      `"MiscellaneousCode"`, `"Title"`, and `"DisplayCitation"`.

  `dates`

  :   A list of date filters. Each entry may include `order`,
      `logicOperator`, `fieldName`, `filter`, `startDate`, and
      `endDate`. Valid `fieldName` values include `"DateOfIssue"`,
      `"ContentBeginDate"`, `"ContentEndDate"`, `"LastEdited"`, and
      `"DateCreated"`. Valid `filter` values include `"BeforeDate"`,
      `"AfterDate"`, `"BetweenDates"`, `"Exactly"`, `"NotEquals"`, and
      `"NotBetween"`.

  `referenceTypes`

  :   A list of Reference Type filters. Each entry may include `order`,
      `logicOperator`, and `referenceType`.

  `referenceGroups`

  :   A list of Reference Type Group filters. Each entry may include
      `order`, `logicOperator`, and `group`.

  `rectangles`

  :   One or more bounding boxes represented as OGC Well-Known Text
      polygon strings, for example
      `"POLYGON((-121.8 45.7,-116.4 45.7,-116.4 42.0,-121.86 42.0,-121.8 45.7))"`.

  `subjectCategories`

  :   A list of Subject Category filters. Each entry may include
      `order`, `logicOperator`, and `subjectCategory`, where
      `subjectCategory` is a numeric Subject Category identifier.

  `digitalResources`

  :   A list of Files and Links filters. Each entry may include `order`,
      `logicOperator`, `type`, `fieldName`, and `searchText`. Valid
      `type` values include `"DigitalFile"`, `"ExternalLink"`, and
      `"WebService"`.

  `physicalCopies`

  :   A list of Physical Copy filters. Each entry may include `order`,
      `logicOperator`, `unitCode`, and `searchText`.

  `collections`

  :   A list of Saved Collection filters. Each entry may include
      `order`, `logicOperator`, and `collection`, where `collection` is
      a numeric Saved Collection identifier.

  `people`

  :   A list of Owner or Creator filters. Each entry may include
      `order`, `logicOperator`, `fieldName`, and `searchText`. Valid
      `fieldName` values include `"Creator"` and `"Owner"`. The
      `searchText` value should be a staff UPN or partner user code.

  For criteria sections that accept multiple entries, `logicOperator`
  can be used to combine or exclude criteria. Common values include
  `"AND"`, `"OR"`, and `"NOT"`. Group operators such as `"ANDGROUP"`,
  `"ORGROUP"`, and `"NOTGROUP"` may be used where supported by the
  ServCat API.

- top:

  Number of entries per page. Defaults to `25`. Use a larger integer,
  such as `1000`, to reduce paging, but avoid values so large that the
  request may time out.

- page:

  One-based page index to return. Defaults to `1`.

- orderby:

  Optional name of a single field by which to sort results.

- sort:

  Optional sort direction. Must be `"ASC"` or `"DESC"` if supplied.

- composite:

  Logical. If `TRUE`, use the composite Advanced Search endpoint, which
  returns additional nested detail such as linked resources and
  associated units. Defaults to `FALSE`.

- secure:

  Logical. Use the secure API?

- api_key:

  Optional secure API key.

## Value

A tibble of Advanced Search result items. Page metadata from the
response is stored in the `"page_detail"` attribute. When
`composite = TRUE`, the returned tibble may include list-columns such as
`linkedResources` and `units`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Quick Search using the Advanced Search endpoint
results <- search_references_advanced(
  criteria = list(
    quickSearch = "Kodiak, goats"
  )
)

results

# View paging metadata
attr(results, "page_detail")

# Request more results per page
results <- search_references_advanced(
  criteria = list(
    quickSearch = "Kodiak, goats"
  ),
  top = 100
)

# Return composite results with linked resources and units
composite_results <- search_references_advanced(
  criteria = list(
    quickSearch = "Kodiak, goats"
  ),
  composite = TRUE
)

# Search public records and sort by issue date
results <- search_references_advanced(
  criteria = list(
    quickSearch = "Kodiak, goats",
    visibility = "public"
  ),
  top = 100,
  page = 1,
  orderby = "dateOfIssue",
  sort = "DESC"
)

# Search by reference type
reports <- search_references_advanced(
  criteria = list(
    referenceTypes = list(
      list(
        order = 1,
        logicOperator = NULL,
        referenceType = "Unpublished Report"
      )
    )
  )
)

# Search within title text
title_results <- search_references_advanced(
  criteria = list(
    textFields = list(
      list(
        order = 1,
        logicOperator = NULL,
        fieldName = "Title",
        searchText = "mountain goat"
      )
    )
  )
)

# Search by date range
date_results <- search_references_advanced(
  criteria = list(
    dates = list(
      list(
        order = 1,
        logicOperator = NULL,
        fieldName = "DateOfIssue",
        filter = "BetweenDates",
        startDate = "2010-01-01",
        endDate = "2020-12-31"
      )
    )
  )
)

# Search for records with public digital files
file_results <- search_references_advanced(
  criteria = list(
    digitalResources = list(
      list(
        order = 1,
        logicOperator = NULL,
        type = "DigitalFile",
        fieldName = NULL,
        searchText = NULL
      )
    )
  )
)
} # }
```
