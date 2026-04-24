#' Search ServCat references by ID
#'
#' @param reference_ids Numeric vector of ServCat reference IDs.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A named list containing detailed information about each reference.
#'
#' @examples
#' \dontrun{
#' # Retrieve detailed information for one reference
#' search_references_by_id(140411)
#'
#' # Retrieve detailed information for multiple references
#' search_references_by_id(c(140411, 140412))
#'
#' # Use the secure API
#' search_references_by_id(
#'   reference_ids = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
search_references_by_id <- function(
    reference_ids,
    secure = FALSE,
    api_key = NULL
) {
  reference_ids <- unique(reference_ids)
  
  validate_reference_id(reference_ids, multiple_ok = TRUE)
  validate_flag(secure)
  
  reference_chunks <- chunk_reference_ids(reference_ids, chunk_size = 25)
  
  references <- reference_chunks |>
    purrr::map(
      \(ids) {
        get_reference_profiles_batch(
          reference_ids = ids,
          secure = secure,
          api_key = api_key
        )
      }
    ) |>
    purrr::list_flatten()
  
  if (length(references) == 0) {
    cli::cli_abort("Could not retrieve information for any of the requested references.")
  }
  
  if (length(references) < length(reference_ids)) {
    ids_returned <- vapply(references, function(ref) ref$referenceId, numeric(1))
    ids_missing <- reference_ids[!(reference_ids %in% ids_returned)]
    cli::cli_warn(
      "Could not retrieve information for the following reference IDs: {.val {ids_missing}}."
    )
  }
  
  references
}

#' Search ServCat references by ID and return basic fields
#'
#' @param reference_ids Numeric vector of ServCat reference IDs.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble containing basic information about each reference.
#'
#' @examples
#' \dontrun{
#' # Retrieve basic fields for one reference
#' search_references_by_id_basic(140411)
#'
#' # Retrieve basic fields for multiple references
#' search_references_by_id_basic(c(140411, 140412))
#'
#' # Use the secure API
#' search_references_by_id_basic(
#'   reference_ids = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
search_references_by_id_basic <- function(
    reference_ids,
    secure = FALSE,
    api_key = NULL
) {
  reference_ids <- unique(reference_ids)
  
  validate_reference_id(reference_ids, multiple_ok = TRUE)
  validate_flag(secure)
  
  servcat_request <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("ReferenceCodeSearch") |>
    httr2::req_url_query(q = reference_ids, .multi = "comma") |>
    httr2::req_perform()
  
  validate_response(servcat_request)
  
  references <- httr2::resp_body_json(servcat_request, simplifyVector = FALSE)
  references <- suppressWarnings(data.table::rbindlist(references, use.names = TRUE, fill = TRUE))
  references <- tibble::as_tibble(references)
  
  if (nrow(references) == 0) {
    cli::cli_abort("Could not retrieve information for any of the requested references.")
  }
  
  if (nrow(references) < length(reference_ids)) {
    ids_missing <- reference_ids[!(reference_ids %in% references$referenceId)]
    cli::cli_warn(
      "Could not retrieve information for the following reference IDs: {.val {ids_missing}}."
    )
  }
  
  references
}

#' Get reference owners from the secure ServCat API
#'
#' @param reference_id A single ServCat reference ID.
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used.
#'
#' @returns A tibble of reference owners.
#'
#' @examples
#' \dontrun{
#' # Retrieve owners for a reference from the secure API
#' get_reference_owners(140411)
#' }
#'
#' @export
get_reference_owners <- function(reference_id, api_key = NULL) {
  validate_reference_id(reference_id)
  
  owners <- servcat_request(secure = TRUE, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "Owners") |>
    httr2::req_perform()
  
  validate_response(owners)
  
  httr2::resp_body_json(owners, simplifyVector = FALSE) |>
    data.table::rbindlist(use.names = TRUE, fill = TRUE) |>
    tibble::as_tibble()
}

#' Get keywords from a ServCat reference
#'
#' @param reference_id A single ServCat reference ID.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A character vector of keywords.
#'
#' @examples
#' \dontrun{
#' # Retrieve keywords for a public reference
#' get_keywords(140411)
#'
#' # Retrieve keywords using the secure API
#' get_keywords(
#'   reference_id = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_keywords <- function(reference_id, secure = FALSE, api_key = NULL) {
  validate_reference_id(reference_id)
  
  keywords <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "Keywords") |>
    httr2::req_perform()
  
  validate_response(keywords)
  
  httr2::resp_body_json(keywords, simplifyVector = FALSE) |>
    unlist(use.names = FALSE) |>
    trimws(which = "both")
}

#' Get external links from a ServCat reference
#'
#' @param reference_id A single ServCat reference ID.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble of external links.
#'
#' @examples
#' \dontrun{
#' # Retrieve external links for a public reference
#' get_external_links(140411)
#'
#' # Retrieve external links using the secure API
#' get_external_links(
#'   reference_id = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_external_links <- function(reference_id, secure = FALSE, api_key = NULL) {
  validate_reference_id(reference_id)
  
  links <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "ExternalLinks") |>
    httr2::req_perform()
  
  validate_response(links)
  
  links <- httr2::resp_body_json(links, simplifyVector = FALSE) |>
    data.table::rbindlist(use.names = TRUE, fill = TRUE) |>
    tibble::as_tibble()
  
  if (nrow(links) > 0) {
    links <- links |>
      dplyr::mutate(lastUpdate = lubridate::ymd_hms(.data$lastUpdate)) |>
      dplyr::arrange(.data$userSort)
  }
  
  links
}

#' Get digital file metadata from a ServCat reference
#'
#' @param reference_id A single ServCat reference ID.
#' @param file_id Optional ServCat file ID.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble of file metadata.
#'
#' @examples
#' \dontrun{
#' # Retrieve metadata for all digital files attached to a reference
#' get_file_info(140411)
#'
#' # Retrieve metadata for a single file attached to a reference
#' files <- get_file_info(140411)
#' get_file_info(
#'   reference_id = 140411,
#'   file_id = files$resourceId[[1]]
#' )
#'
#' # Retrieve file metadata using the secure API
#' get_file_info(
#'   reference_id = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_file_info <- function(reference_id, file_id, secure = FALSE, api_key = NULL) {
  validate_reference_id(reference_id)
  
  if (missing(file_id)) {
    files <- servcat_request(secure = secure, api_key = api_key) |>
      httr2::req_url_path_append("Reference", reference_id, "DigitalFiles") |>
      httr2::req_perform()
  } else {
    files <- servcat_request(secure = secure, api_key = api_key) |>
      httr2::req_url_path_append("Reference", reference_id, "DigitalFiles", file_id) |>
      httr2::req_perform()
  }
  
  validate_response(files)
  
  files <- httr2::resp_body_json(files, simplifyVector = FALSE)
  
  if (!missing(file_id)) {
    files <- list(files)
  }
  
  files <- suppressWarnings(data.table::rbindlist(files, use.names = TRUE, fill = TRUE)) |>
    tibble::as_tibble()
  
  if (nrow(files) > 0) {
    files <- files |>
      dplyr::select(
        userSort,
        resourceId,
        lastUpdate,
        description,
        fileName,
        fileSize_kb = fileSize,
        extension,
        mimeType,
        downloadLink,
      ) |>
      dplyr::mutate(
        fileSize_kb = .data$fileSize_kb / 1024,
        lastUpdate = lubridate::ymd_hms(.data$lastUpdate)
      ) |>
      dplyr::arrange(.data$userSort)
  }
  
  files
}

#' Get bibliography metadata for a ServCat reference from the secure ServCat API
#'
#' @param reference_id A single ServCat reference ID.
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used.
#'
#' @returns A named list.
#'
#' @examples
#' \dontrun{
#' # Retrieve bibliography metadata from the secure API
#' get_bibliography(140411)
#' }
#'
#' @export
get_bibliography <- function(reference_id, api_key = NULL) {
  validate_reference_id(reference_id)
  
  bib <- servcat_request(secure = TRUE, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "Bibliography") |>
    httr2::req_perform()
  
  validate_response(bib)
  
  bib <- httr2::resp_body_json(bib, simplifyVector = FALSE)
  names(bib) <- stringr::str_replace(names(bib), "^abstract$", "description")
  
  bib
}

#' Get lifecycle information from the secure ServCat API
#'
#' @param reference_id A single ServCat reference ID.
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used.
#'
#' @returns A named list.
#'
#' @examples
#' \dontrun{
#' # Retrieve lifecycle information from the secure API
#' get_lifecycle_info(140411)
#' }
#'
#' @export
get_lifecycle_info <- function(reference_id, api_key = NULL) {
  validate_reference_id(reference_id)
  
  lifecycle_info <- servcat_request(secure = TRUE, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "LifecycleConstraints") |>
    httr2::req_perform()
  
  validate_response(lifecycle_info)
  
  httr2::resp_body_json(lifecycle_info, simplifyVector = FALSE)
}

#' Download files from a ServCat reference
#'
#' @param reference_id A single ServCat reference ID.
#' @param resource_ids Optional numeric vector of ServCat resource IDs to
#'   download. If omitted, all files attached to the reference are downloaded.
#' @param path Directory where files should be saved. Defaults to `"downloads"`.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#' @param overwrite Logical. Overwrite existing files if they already exist?
#'
#' @returns A tibble with one row per downloaded file.
#'
#' @examples
#' \dontrun{
#' # Download all files attached to a reference
#' download_reference_files(
#'   reference_id = 140411,
#'   path = tempdir()
#' )
#'
#' # Download one or more specific files by resource ID
#' files <- get_file_info(140411)
#' download_reference_files(
#'   reference_id = 140411,
#'   resource_ids = files$resourceId[1],
#'   path = tempdir()
#' )
#'
#' # Overwrite existing files if they already exist
#' download_reference_files(
#'   reference_id = 140411,
#'   path = tempdir(),
#'   overwrite = TRUE
#' )
#'
#' # Download files using the secure API
#' download_reference_files(
#'   reference_id = 140411,
#'   path = tempdir(),
#'   secure = TRUE
#' )
#' }
#'
#' @export
download_reference_files <- function(
    reference_id,
    resource_ids,
    path = "downloads",
    secure = FALSE,
    api_key = NULL,
    overwrite = FALSE
) {
  validate_reference_id(reference_id)
  validate_flag(secure)
  validate_flag(overwrite)
  
  if (!is.character(path) || length(path) != 1 || is.na(path) || !nzchar(path)) {
    cli::cli_abort("{.arg path} must be a single non-empty character string.")
  }
  
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE)
  }
  
  files <- get_file_info(
    reference_id = reference_id,
    secure = secure,
    api_key = api_key
  )
  
  if (nrow(files) == 0) {
    cli::cli_warn("No files were found for ServCat reference {.val {reference_id}}.")
    
    return(tibble::tibble(
      referenceId = numeric(),
      resourceId = numeric(),
      fileName = character(),
      localPath = character(),
      downloadLink = character()
    ))
  }
  
  if (!missing(resource_ids)) {
    if (!is.numeric(resource_ids) || !all(resource_ids == floor(resource_ids))) {
      cli::cli_abort("{.arg resource_ids} must be numeric whole number(s).")
    }
    
    resource_ids <- unique(resource_ids)
    
    ids_missing <- resource_ids[!(resource_ids %in% files$resourceId)]
    if (length(ids_missing) > 0) {
      cli::cli_warn(
        "The following resource IDs were not found on reference {.val {reference_id}}: {.val {ids_missing}}."
      )
    }
    
    files <- files |>
      dplyr::filter(.data$resourceId %in% resource_ids)
    
    if (nrow(files) == 0) {
      cli::cli_abort(
        "None of the requested {.arg resource_ids} were found for reference {.val {reference_id}}."
      )
    }
  }
  
  build_output_path <- function(file_name, resource_id, path, overwrite) {
    if (is.na(file_name) || !nzchar(file_name)) {
      file_name <- paste0(resource_id, ".bin")
    }
    
    output_path <- file.path(path, file_name)
    
    if (file.exists(output_path) && !overwrite) {
      ext <- tools::file_ext(file_name)
      
      stem <- if (nzchar(ext)) {
        sub(paste0("\\.", ext, "$"), "", file_name)
      } else {
        file_name
      }
      
      file_name <- if (nzchar(ext)) {
        paste0(stem, "_", resource_id, ".", ext)
      } else {
        paste0(stem, "_", resource_id)
      }
      
      output_path <- file.path(path, file_name)
    }
    
    output_path
  }
  
  purrr::pmap_dfr(
    .l = list(
      resource_id = files$resourceId,
      file_name = files$fileName,
      download_link = files$downloadLink
    ),
    .f = function(resource_id, file_name, download_link) {
      resp <- servcat_request(secure = secure, api_key = api_key) |>
        httr2::req_url_path_append("DownloadFile", resource_id) |>
        httr2::req_perform()
      
      validate_response(resp)
      
      output_path <- build_output_path(
        file_name = file_name,
        resource_id = resource_id,
        path = path,
        overwrite = overwrite
      )
      
      writeBin(
        object = httr2::resp_body_raw(resp),
        con = output_path
      )
      
      tibble::tibble(
        referenceId = reference_id,
        resourceId = resource_id,
        fileName = basename(output_path),
        localPath = normalizePath(output_path, winslash = "/", mustWork = FALSE),
        downloadLink = download_link
      )
    }
  ) |>
    dplyr::arrange(.data$resourceId)
}

#' Get units associated with a ServCat reference
#'
#' @param reference_id A single ServCat reference ID.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble of units associated with the reference.
#'
#' @examples
#' \dontrun{
#' # Retrieve units associated with a public reference
#' get_units(140411)
#'
#' # Retrieve units using the secure API
#' get_units(
#'   reference_id = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_units <- function(reference_id, secure = FALSE, api_key = NULL) {
  validate_reference_id(reference_id)
  validate_flag(secure)
  
  units <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "Units") |>
    httr2::req_perform()
  
  validate_response(units)
  
  units <- httr2::resp_body_json(units, simplifyVector = FALSE)
  
  if (length(units) == 0) {
    return(tibble::tibble())
  }
  
  suppressWarnings(
    data.table::rbindlist(units, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble()
}

#' Get geographic bounding boxes from a ServCat reference
#'
#' @param reference_id A single ServCat reference ID.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble of bounding box coordinates associated with the reference.
#'
#' @examples
#' \dontrun{
#' # Retrieve geographic bounding boxes for a public reference
#' get_bounding_boxes(140411)
#'
#' # Retrieve geographic bounding boxes using the secure API
#' get_bounding_boxes(
#'   reference_id = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_bounding_boxes <- function(reference_id, secure = FALSE, api_key = NULL) {
  validate_reference_id(reference_id)
  validate_flag(secure)
  
  bounding_boxes <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "BoundingBoxes") |>
    httr2::req_perform()
  
  validate_response(bounding_boxes)
  
  bounding_boxes <- httr2::resp_body_json(
    bounding_boxes,
    simplifyVector = FALSE
  )
  
  if (length(bounding_boxes) == 0) {
    return(tibble::tibble())
  }
  
  suppressWarnings(
    data.table::rbindlist(bounding_boxes, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble()
}

#' Get subject categories from a ServCat reference
#'
#' @param reference_id A single ServCat reference ID.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble of subject categories associated with the reference.
#'
#' @examples
#' \dontrun{
#' # Retrieve subject categories for a public reference
#' get_subjects(140411)
#'
#' # Retrieve subject categories using the secure API
#' get_subjects(
#'   reference_id = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_subjects <- function(reference_id, secure = FALSE, api_key = NULL) {
  validate_reference_id(reference_id)
  validate_flag(secure)
  
  subjects <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "Subjects") |>
    httr2::req_perform()
  
  validate_response(subjects)
  
  subjects <- httr2::resp_body_json(subjects, simplifyVector = FALSE)
  
  if (length(subjects) == 0) {
    return(tibble::tibble())
  }
  
  suppressWarnings(
    data.table::rbindlist(subjects, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble()
}

#' Get taxa associated with a ServCat reference
#'
#' @param reference_id A single ServCat reference ID.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble of taxa associated with the reference.
#'
#' @examples
#' \dontrun{
#' # Retrieve taxa associated with a public reference
#' get_taxa(140411)
#'
#' # Retrieve taxa using the secure API
#' get_taxa(
#'   reference_id = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_taxa <- function(reference_id, secure = FALSE, api_key = NULL) {
  validate_reference_id(reference_id)
  validate_flag(secure)
  
  taxa <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "Taxa") |>
    httr2::req_perform()
  
  validate_response(taxa)
  
  taxa <- httr2::resp_body_json(taxa, simplifyVector = FALSE)
  
  if (length(taxa) == 0) {
    return(tibble::tibble())
  }
  
  suppressWarnings(
    data.table::rbindlist(taxa, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble()
}

#' Execute an Advanced Search
#'
#' Executes a ServCat Advanced Search using a POST request. Search criteria are
#' posted in the request body, while paging and sorting parameters are sent as
#' URI query parameters.
#'
#' @param criteria A named list of Advanced Search criteria. Supported top-level
#'   fields include:
#'
#'   \describe{
#'     \item{`quickSearch`}{A character string to search using ServCat Quick
#'       Search. If supplied, Quick Search is the primary source of results, and
#'       other filters are applied to those results.}
#'     \item{`visibility`}{Optional visibility filter. Use `"public"` to return
#'       only public records, `"internal"` to return only internal records, or
#'       `NULL` to return both when available. Non-secure services can return
#'       only public records.}
#'     \item{`legacy`}{Optional legacy-status filter. Use `"excludelegacy"` to
#'       return only non-legacy records, `"onlylegacy"` to return only legacy
#'       records, or `NULL` to ignore legacy status.}
#'     \item{`version`}{Optional version filter. Use `"all"` to include all
#'       versions of versioned records, or `NULL` to return only the most recent
#'       version.}
#'     \item{`regions`}{A list of Region filters. Each entry may include
#'       `order`, `logicOperator`, and `unitCode`.}
#'     \item{`units`}{A list of Unit filters. Each entry may include `order`,
#'       `logicOperator`, `unitCode`, `linked`, and `approved`.}
#'     \item{`textFields`}{A list of text-field filters. Each entry may include
#'       `order`, `logicOperator`, `fieldName`, and `searchText`. Valid
#'       `fieldName` values include `"Abstract"`, `"Notes"`,
#'       `"TableOfContent"`, `"ContactName"`, `"Publisher"`, `"Keyword"`,
#'       `"MiscellaneousCode"`, `"Title"`, and `"DisplayCitation"`.}
#'     \item{`dates`}{A list of date filters. Each entry may include `order`,
#'       `logicOperator`, `fieldName`, `filter`, `startDate`, and `endDate`.
#'       Valid `fieldName` values include `"DateOfIssue"`, `"ContentBeginDate"`,
#'       `"ContentEndDate"`, `"LastEdited"`, and `"DateCreated"`. Valid
#'       `filter` values include `"BeforeDate"`, `"AfterDate"`,
#'       `"BetweenDates"`, `"Exactly"`, `"NotEquals"`, and `"NotBetween"`.}
#'     \item{`referenceTypes`}{A list of Reference Type filters. Each entry may
#'       include `order`, `logicOperator`, and `referenceType`.}
#'     \item{`referenceGroups`}{A list of Reference Type Group filters. Each
#'       entry may include `order`, `logicOperator`, and `group`.}
#'     \item{`rectangles`}{One or more bounding boxes represented as OGC
#'       Well-Known Text polygon strings, for example
#'       `"POLYGON((-121.8 45.7,-116.4 45.7,-116.4 42.0,-121.86 42.0,-121.8 45.7))"`.}
#'     \item{`subjectCategories`}{A list of Subject Category filters. Each
#'       entry may include `order`, `logicOperator`, and `subjectCategory`, where
#'       `subjectCategory` is a numeric Subject Category identifier.}
#'     \item{`digitalResources`}{A list of Files and Links filters. Each entry
#'       may include `order`, `logicOperator`, `type`, `fieldName`, and
#'       `searchText`. Valid `type` values include `"DigitalFile"`,
#'       `"ExternalLink"`, and `"WebService"`.}
#'     \item{`physicalCopies`}{A list of Physical Copy filters. Each entry may
#'       include `order`, `logicOperator`, `unitCode`, and `searchText`.}
#'     \item{`collections`}{A list of Saved Collection filters. Each entry may
#'       include `order`, `logicOperator`, and `collection`, where `collection`
#'       is a numeric Saved Collection identifier.}
#'     \item{`people`}{A list of Owner or Creator filters. Each entry may
#'       include `order`, `logicOperator`, `fieldName`, and `searchText`. Valid
#'       `fieldName` values include `"Creator"` and `"Owner"`. The `searchText`
#'       value should be a staff UPN or partner user code.}
#'   }
#'
#'   For criteria sections that accept multiple entries, `logicOperator` can be
#'   used to combine or exclude criteria. Common values include `"AND"`,
#'   `"OR"`, and `"NOT"`. Group operators such as `"ANDGROUP"`, `"ORGROUP"`,
#'   and `"NOTGROUP"` may be used where supported by the ServCat API.
#'
#' @param top Number of entries per page. Defaults to `25`. Use a larger
#'   integer, such as `1000`, to reduce paging, but avoid values so large that
#'   the request may time out.
#' @param page One-based page index to return. Defaults to `1`.
#' @param orderby Optional name of a single field by which to sort results.
#' @param sort Optional sort direction. Must be `"ASC"` or `"DESC"` if supplied.
#' @param composite Logical. If `TRUE`, use the composite Advanced Search
#'   endpoint, which returns additional nested detail such as linked resources
#'   and associated units. Defaults to `FALSE`.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A tibble of Advanced Search result items. Page metadata from the
#'   response is stored in the `"page_detail"` attribute. When
#'   `composite = TRUE`, the returned tibble may include list-columns such as
#'   `linkedResources` and `units`.
#'
#' @examples
#' \dontrun{
#' # Quick Search using the Advanced Search endpoint
#' results <- search_references_advanced(
#'   criteria = list(
#'     quickSearch = "Kodiak, goats"
#'   )
#' )
#'
#' results
#'
#' # View paging metadata
#' attr(results, "page_detail")
#'
#' # Request more results per page
#' results <- search_references_advanced(
#'   criteria = list(
#'     quickSearch = "Kodiak, goats"
#'   ),
#'   top = 100
#' )
#'
#' # Return composite results with linked resources and units
#' composite_results <- search_references_advanced(
#'   criteria = list(
#'     quickSearch = "Kodiak, goats"
#'   ),
#'   composite = TRUE
#' )
#'
#' # Search public records and sort by issue date
#' results <- search_references_advanced(
#'   criteria = list(
#'     quickSearch = "Kodiak, goats",
#'     visibility = "public"
#'   ),
#'   top = 100,
#'   page = 1,
#'   orderby = "dateOfIssue",
#'   sort = "DESC"
#' )
#'
#' # Search by reference type
#' reports <- search_references_advanced(
#'   criteria = list(
#'     referenceTypes = list(
#'       list(
#'         order = 1,
#'         logicOperator = NULL,
#'         referenceType = "Unpublished Report"
#'       )
#'     )
#'   )
#' )
#'
#' # Search within title text
#' title_results <- search_references_advanced(
#'   criteria = list(
#'     textFields = list(
#'       list(
#'         order = 1,
#'         logicOperator = NULL,
#'         fieldName = "Title",
#'         searchText = "mountain goat"
#'       )
#'     )
#'   )
#' )
#'
#' # Search by date range
#' date_results <- search_references_advanced(
#'   criteria = list(
#'     dates = list(
#'       list(
#'         order = 1,
#'         logicOperator = NULL,
#'         fieldName = "DateOfIssue",
#'         filter = "BetweenDates",
#'         startDate = "2010-01-01",
#'         endDate = "2020-12-31"
#'       )
#'     )
#'   )
#' )
#'
#' # Search for records with public digital files
#' file_results <- search_references_advanced(
#'   criteria = list(
#'     digitalResources = list(
#'       list(
#'         order = 1,
#'         logicOperator = NULL,
#'         type = "DigitalFile",
#'         fieldName = NULL,
#'         searchText = NULL
#'       )
#'     )
#'   )
#' )
#' }
#'
#' @export
search_references_advanced <- function(
    criteria,
    top = 25,
    page = 1,
    orderby = NULL,
    sort = NULL,
    composite = FALSE,
    secure = FALSE,
    api_key = NULL
) {
  validate_flag(secure)
  validate_flag(composite)
  
  if (!is.list(criteria) || is.null(names(criteria))) {
    cli::cli_abort(
      "{.arg criteria} must be a named list of Advanced Search criteria."
    )
  }
  
  if (
    !is.numeric(top) ||
    length(top) != 1 ||
    is.na(top) ||
    top != floor(top) ||
    top < 1
  ) {
    cli::cli_abort("{.arg top} must be a single positive whole number.")
  }
  
  if (
    !is.numeric(page) ||
    length(page) != 1 ||
    is.na(page) ||
    page != floor(page) ||
    page < 1
  ) {
    cli::cli_abort("{.arg page} must be a single positive whole number.")
  }
  
  if (
    !is.null(orderby) &&
    (
      !is.character(orderby) ||
      length(orderby) != 1 ||
      is.na(orderby) ||
      !nzchar(orderby)
    )
  ) {
    cli::cli_abort(
      "{.arg orderby} must be `NULL` or a single non-empty character string."
    )
  }
  
  if (!is.null(sort)) {
    if (!is.character(sort) || length(sort) != 1 || is.na(sort)) {
      cli::cli_abort(
        "{.arg sort} must be `NULL`, {.val ASC}, or {.val DESC}."
      )
    }
    
    sort <- toupper(sort)
    
    if (!(sort %in% c("ASC", "DESC"))) {
      cli::cli_abort(
        "{.arg sort} must be `NULL`, {.val ASC}, or {.val DESC}."
      )
    }
  }
  
  req <- servcat_request(secure = secure, api_key = api_key)
  
  if (isTRUE(composite)) {
    req <- req |>
      httr2::req_url_path_append("AdvancedSearch", "Composite")
  } else {
    req <- req |>
      httr2::req_url_path_append("AdvancedSearch")
  }
  
  req <- req |>
    httr2::req_headers(
      accept = "application/json"
    ) |>
    httr2::req_url_query(
      top = top,
      page = page
    ) |>
    httr2::req_body_json(
      criteria,
      auto_unbox = TRUE
    )
  
  if (!is.null(orderby)) {
    req <- req |>
      httr2::req_url_query(orderby = orderby)
  }
  
  if (!is.null(sort)) {
    req <- req |>
      httr2::req_url_query(sort = sort)
  }
  
  resp <- req |>
    httr2::req_perform()
  
  validate_response(resp)
  
  response <- httr2::resp_body_json(
    resp,
    simplifyVector = FALSE
  )
  
  items <- if (is.null(response$items)) {
    list()
  } else {
    response$items
  }
  
  results <- if (length(items) == 0) {
    tibble::tibble()
  } else {
    suppressWarnings(
      data.table::rbindlist(items, use.names = TRUE, fill = TRUE)
    ) |>
      tibble::as_tibble()
  }
  
  attr(results, "page_detail") <- if (is.null(response$pageDetail)) {
    list()
  } else {
    response$pageDetail
  }
  
  results
}


#' Get references in a saved collection
#'
#' Retrieves the references belonging to a ServCat Saved Collection using the
#' composite endpoint, which returns additional nested detail such as linked
#' resources and associated units.
#'
#' @param collection_id A single ServCat Saved Collection ID.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A tibble of composite reference records. Nested fields such as
#'   `linkedResources` and `units` are returned as list-columns.
#'
#' @examples
#' \dontrun{
#' refs <- get_collection_references(1397)
#'
#' refs
#'
#' # View linked resources for the first reference
#' refs$linkedResources[[1]]
#'
#' # View associated units for the first reference
#' refs$units[[1]]
#' }
#'
#' @export
get_collection_references <- function(
    collection_id,
    secure = FALSE,
    api_key = NULL
) {
  validate_flag(secure)
  
  if (
    !is.numeric(collection_id) ||
    length(collection_id) != 1 ||
    is.na(collection_id) ||
    collection_id != floor(collection_id) ||
    collection_id < 1
  ) {
    cli::cli_abort(
      "{.arg collection_id} must be a single positive whole number."
    )
  }
  
  collection_id <- as.integer(collection_id)
  
  refs_resp <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("SavedCollection", "Composite", collection_id) |>
    httr2::req_headers(
      accept = "application/json"
    ) |>
    httr2::req_perform()
  
  validate_response(refs_resp)
  
  refs <- httr2::resp_body_json(
    refs_resp,
    simplifyVector = FALSE
  )
  
  if (length(refs) == 0) {
    return(tibble::tibble())
  }
  
  # Be defensive in case the API ever returns a single object instead of an
  # array of objects.
  if (!is.null(names(refs))) {
    refs <- list(refs)
  }
  
  refs <- lapply(
    refs,
    function(ref) {
      ref <- lapply(
        ref,
        function(x) {
          if (is.null(x)) {
            return(NA)
          }
          
          if (is.atomic(x) && length(x) <= 1) {
            return(x)
          }
          
          list(x)
        }
      )
      
      tibble::as_tibble(ref)
    }
  )
  
  dplyr::bind_rows(refs)
}

