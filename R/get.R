#' Get ServCat references by ID
#'
#' @param reference_ids Numeric vector of ServCat reference IDs.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A named list containing detailed information about each reference.
#'   Field names returned by the API are preserved.
#'
#' @examples
#' \dontrun{
#' # Retrieve detailed information for one reference
#' get_references(140411)
#'
#' # Retrieve detailed information for multiple references
#' get_references(c(140411, 140412))
#'
#' # Use the secure API
#' get_references(
#'   reference_ids = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_references <- function(
    reference_ids,
    secure = FALSE,
    api_key = NULL
) {
  validate_reference_id(reference_ids, multiple_ok = TRUE)
  validate_flag(secure)
  
  reference_ids <- unique(reference_ids)
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
    ids_returned <- vapply(
      references,
      function(ref) rlang::`%||%`(ref$referenceId, NA_real_),
      numeric(1)
    )
    
    ids_missing <- reference_ids[!(reference_ids %in% ids_returned)]
    
    cli::cli_warn(
      "Could not retrieve information for the following reference IDs: {.val {ids_missing}}."
    )
  }
  
  references
}


#' Get ServCat reference summaries by ID
#'
#' @param reference_ids Numeric vector of ServCat reference IDs.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble containing summary information about each reference.
#'
#' @examples
#' \dontrun{
#' # Retrieve summary fields for one reference
#' get_reference_summaries(140411)
#'
#' # Retrieve summary fields for multiple references
#' get_reference_summaries(c(140411, 140412))
#'
#' # Long vectors are automatically requested in chunks
#' get_reference_summaries(c(140411, 140412, 140413))
#'
#' # Use the secure API
#' get_reference_summaries(
#'   reference_ids = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_reference_summaries <- function(
    reference_ids,
    secure = FALSE,
    api_key = NULL
) {
  validate_reference_id(reference_ids, multiple_ok = TRUE)
  validate_flag(secure)
  
  reference_ids <- unique(reference_ids)
  reference_chunks <- chunk_reference_ids(reference_ids, chunk_size = 25)
  
  references <- reference_chunks |>
    purrr::map_dfr(
      \(ids) {
        resp <- servcat_request(secure = secure, api_key = api_key) |>
          httr2::req_url_path_append("ReferenceCodeSearch") |>
          httr2::req_url_query(q = collapse_reference_ids(ids)) |>
          httr2::req_perform()
        
        validate_response(resp)
        
        httr2::resp_body_json(resp, simplifyVector = FALSE) |>
          json_to_tibble()
      }
    )
  
  if (nrow(references) == 0) {
    cli::cli_abort("Could not retrieve information for any of the requested references.")
  }
  
  if ("referenceId" %in% names(references) && nrow(references) < length(reference_ids)) {
    ids_missing <- reference_ids[!(reference_ids %in% references$referenceId)]
    
    cli::cli_warn(
      "Could not retrieve information for the following reference IDs: {.val {ids_missing}}."
    )
  }
  
  references
}


#' Get owners for a ServCat reference
#'
#' Retrieves owners for a ServCat reference from the secure ServCat API. This
#' endpoint requires a valid `SERVCAT_API_KEY` environment variable unless
#' `api_key` is supplied directly.
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
#' get_owners(140411)
#' }
#'
#' @export
get_owners <- function(reference_id, api_key = NULL) {
  validate_reference_id(reference_id)

  owners <- servcat_request(secure = TRUE, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "Owners") |>
    httr2::req_perform()

  validate_response(owners)

  httr2::resp_body_json(owners, simplifyVector = FALSE) |>
    json_to_tibble()
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
  validate_flag(secure)

  keywords <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "Keywords") |>
    httr2::req_perform()

  validate_response(keywords)

  keywords <- httr2::resp_body_json(keywords, simplifyVector = FALSE)

  if (length(keywords) == 0) {
    return(character())
  }

  keywords |>
    unlist(use.names = FALSE) |>
    trimws(which = "both")
}


#' Get links from a ServCat reference
#'
#' @param reference_id A single ServCat reference ID.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble of links.
#'
#' @examples
#' \dontrun{
#' # Retrieve links for a public reference
#' get_links(140411)
#'
#' # Retrieve links using the secure API
#' get_links(
#'   reference_id = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_links <- function(reference_id, secure = FALSE, api_key = NULL) {
  validate_reference_id(reference_id)
  validate_flag(secure)

  links <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "ExternalLinks") |>
    httr2::req_perform()

  validate_response(links)

  links <- httr2::resp_body_json(links, simplifyVector = FALSE) |>
    json_to_tibble()

  if (nrow(links) > 0 && "lastUpdate" %in% names(links)) {
    links <- links |>
      dplyr::mutate(lastUpdate = lubridate::ymd_hms(.data$lastUpdate))
  }

  if (nrow(links) > 0 && "userSort" %in% names(links)) {
    links <- links |>
      dplyr::arrange(.data$userSort)
  }

  links
}


#' Get digital file information from a ServCat reference
#'
#' @param reference_id A single ServCat reference ID.
#' @param file_id Optional ServCat file ID. If supplied, only that file is
#'   returned.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble of file information. The API field `fileSize` is preserved.
#'   When available, an additional `fileSize_kb` column is added by dividing
#'   `fileSize` by 1024.
#'
#' @examples
#' \dontrun{
#' # Retrieve information for all files attached to a reference
#' get_files(140411)
#'
#' # Retrieve information for a single file attached to a reference
#' files <- get_files(140411)
#' get_files(
#'   reference_id = 140411,
#'   file_id = files$resourceId[[1]]
#' )
#'
#' # Retrieve file information using the secure API
#' get_files(
#'   reference_id = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_files <- function(reference_id, file_id = NULL, secure = FALSE, api_key = NULL) {
  validate_reference_id(reference_id)
  validate_flag(secure)
  
  if (!is.null(file_id)) {
    validate_whole_number(file_id, arg = "file_id")
  }
  
  req <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "DigitalFiles")
  
  if (!is.null(file_id)) {
    req <- req |>
      httr2::req_url_path_append(file_id)
  }
  
  files_resp <- req |>
    httr2::req_perform()
  
  validate_response(files_resp)
  
  files <- httr2::resp_body_json(files_resp, simplifyVector = FALSE)
  
  if (!is.null(file_id)) {
    files <- list(files)
  }
  
  files <- json_to_tibble(files)
  
  if (nrow(files) == 0) {
    return(files)
  }
  
  files <- files |>
    dplyr::select(
      dplyr::any_of(c(
        "userSort",
        "resourceId",
        "lastUpdate",
        "description",
        "fileName",
        "fileSize",
        "extension",
        "mimeType",
        "downloadLink"
      ))
    )
  
  if ("fileSize" %in% names(files)) {
    files <- files |>
      dplyr::mutate(fileSize_kb = .data$fileSize / 1024)
  }
  
  if ("lastUpdate" %in% names(files)) {
    files <- files |>
      dplyr::mutate(lastUpdate = lubridate::ymd_hms(.data$lastUpdate))
  }
  
  if ("userSort" %in% names(files)) {
    files <- files |>
      dplyr::arrange(.data$userSort)
  }
  
  files
}


#' Get bibliography metadata for a ServCat reference
#'
#' Retrieves bibliography metadata for a ServCat reference from the secure
#' ServCat API. This endpoint requires a valid `SERVCAT_API_KEY` environment
#' variable unless `api_key` is supplied directly.
#'
#' @param reference_id A single ServCat reference ID.
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used.
#'
#' @returns A named list. Field names returned by the API are preserved,
#'   including `abstract` when present.
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
  
  httr2::resp_body_json(bib, simplifyVector = FALSE)
}


#' Get lifecycle information for a ServCat reference
#'
#' Retrieves lifecycle information for a ServCat reference from the secure
#' ServCat API. This endpoint requires a valid `SERVCAT_API_KEY` environment
#' variable unless `api_key` is supplied directly.
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
#' get_lifecycle(140411)
#' }
#'
#' @export
get_lifecycle <- function(reference_id, api_key = NULL) {
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
#'   download. If `NULL`, all files attached to the reference are downloaded.
#' @param path Directory where files should be saved. Defaults to `"downloads"`.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#' @param overwrite Logical. Overwrite existing files if they already exist?
#'
#' @returns A tibble with one row per requested file and the columns
#'   `referenceId`, `resourceId`, `fileName`, `localPath`, `downloadLink`,
#'   `success`, and `error`. Failed downloads are reported in the returned
#'   tibble rather than aborting the entire batch.
#'
#' @examples
#' \dontrun{
#' # Download all public files attached to a reference
#' downloads <- download_files(
#'   reference_id = 140411,
#'   path = tempdir()
#' )
#'
#' downloads
#'
#' # Check whether each file downloaded successfully
#' downloads[, c("resourceId", "success", "error")]
#'
#' # Download one or more specific files by resource ID
#' files <- get_files(140411)
#' download_files(
#'   reference_id = 140411,
#'   resource_ids = files$resourceId[1],
#'   path = tempdir()
#' )
#'
#' # Overwrite existing files if they already exist
#' download_files(
#'   reference_id = 140411,
#'   path = tempdir(),
#'   overwrite = TRUE
#' )
#'
#' # Download internal or restricted files using the secure API
#' download_files(
#'   reference_id = 140411,
#'   path = tempdir(),
#'   secure = TRUE
#' )
#' }
#'
#' @export
download_files <- function(
    reference_id,
    resource_ids = NULL,
    path = "downloads",
    secure = FALSE,
    api_key = NULL,
    overwrite = FALSE
) {
  validate_reference_id(reference_id)
  validate_flag(secure)
  validate_flag(overwrite)
  validate_string(path)
  
  if (!is.null(resource_ids)) {
    validate_whole_number(resource_ids, arg = "resource_ids", multiple_ok = TRUE)
    resource_ids <- unique(resource_ids)
  }
  
  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  
  if (!dir.exists(path)) {
    cli::cli_abort("Could not create output directory {.path {path}}.")
  }
  
  files <- tryCatch(
    get_files(
      reference_id = reference_id,
      secure = secure,
      api_key = api_key
    ),
    error = function(e) e
  )
  
  if (inherits(files, "error")) {
    err <- restricted_resource_error(
      reference_id = reference_id,
      secure = secure
    )
    
    cli::cli_warn(
      "Could not retrieve file metadata for ServCat reference {.val {reference_id}}. See the returned {.field error} column for details."
    )
    
    failed_resource_ids <- if (is.null(resource_ids)) {
      NA_real_
    } else {
      resource_ids
    }
    
    return(tibble::tibble(
      referenceId = reference_id,
      resourceId = failed_resource_ids,
      fileName = NA_character_,
      localPath = NA_character_,
      downloadLink = NA_character_,
      success = FALSE,
      error = err
    ))
  }
  
  if (nrow(files) == 0) {
    cli::cli_warn("No files were found for ServCat reference {.val {reference_id}}.")
    
    return(tibble::tibble(
      referenceId = numeric(),
      resourceId = numeric(),
      fileName = character(),
      localPath = character(),
      downloadLink = character(),
      success = logical(),
      error = character()
    ))
  }
  
  required_cols <- c("resourceId", "fileName", "downloadLink")
  missing_cols <- setdiff(required_cols, names(files))
  
  if (length(missing_cols) > 0) {
    cli::cli_abort(
      "File metadata is missing required column(s): {.val {missing_cols}}."
    )
  }
  
  if (!is.null(resource_ids)) {
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
  
  downloads <- purrr::pmap_dfr(
    .l = list(
      resource_id = files$resourceId,
      file_name = files$fileName,
      download_link = files$downloadLink
    ),
    .f = function(resource_id, file_name, download_link) {
      output_path <- build_download_path(
        path = path,
        file_name = file_name,
        resource_id = resource_id,
        overwrite = overwrite
      )
      
      tryCatch(
        {
          resp <- servcat_request(secure = secure, api_key = api_key) |>
            httr2::req_url_path_append("DownloadFile", resource_id) |>
            httr2::req_perform()
          
          validate_response(
            resp,
            nice_msg_400 = c(
              "i" = paste0("ServCat denied access to file resource ", resource_id, "."),
              restricted_file_message(secure = secure)
            )
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
            downloadLink = download_link,
            success = TRUE,
            error = NA_character_
          )
        },
        error = function(e) {
          tibble::tibble(
            referenceId = reference_id,
            resourceId = resource_id,
            fileName = basename(output_path),
            localPath = normalizePath(output_path, winslash = "/", mustWork = FALSE),
            downloadLink = download_link,
            success = FALSE,
            error = restricted_resource_error(
              reference_id = reference_id,
              resource_id = resource_id,
              secure = secure
            )
          )
        }
      )
    }
  ) |>
    dplyr::arrange(.data$resourceId)
  
  failed <- downloads |>
    dplyr::filter(!.data$success)
  
  if (nrow(failed) > 0) {
    cli::cli_warn(
      "Failed to download {nrow(failed)} file{?s}. See the {.field error} column for details."
    )
  }
  
  downloads
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

  httr2::resp_body_json(units, simplifyVector = FALSE) |>
    json_to_tibble()
}


#' Get bounding boxes from a ServCat reference
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
#' # Retrieve bounding boxes for a public reference
#' get_bboxes(140411)
#'
#' # Retrieve bounding boxes using the secure API
#' get_bboxes(
#'   reference_id = 140411,
#'   secure = TRUE
#' )
#' }
#'
#' @export
get_bboxes <- function(reference_id, secure = FALSE, api_key = NULL) {
  validate_reference_id(reference_id)
  validate_flag(secure)

  bounding_boxes <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Reference", reference_id, "BoundingBoxes") |>
    httr2::req_perform()

  validate_response(bounding_boxes)

  httr2::resp_body_json(bounding_boxes, simplifyVector = FALSE) |>
    json_to_tibble()
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

  httr2::resp_body_json(subjects, simplifyVector = FALSE) |>
    json_to_tibble()
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

  httr2::resp_body_json(taxa, simplifyVector = FALSE) |>
    json_to_tibble()
}


#' Search ServCat references
#'
#' Executes a ServCat Advanced Search using a POST request. Search criteria are
#' posted in the request body, while paging and sorting parameters are sent as
#' URI query parameters.
#'
#' `NULL` values in `criteria` are recursively omitted before the JSON request
#' body is serialized.
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
#'       `NULL` to omit the visibility filter. Non-secure services can return
#'       only public records.}
#'     \item{`legacy`}{Optional legacy-status filter. Use `"excludelegacy"` to
#'       return only non-legacy records, `"onlylegacy"` to return only legacy
#'       records, or `NULL` to omit the legacy filter.}
#'     \item{`version`}{Optional version filter. Use `"all"` to include all
#'       versions of versioned records, or `NULL` to omit the version filter.}
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
#' @param page One-based page index to return. Defaults to `1`. If
#'   `all_pages = TRUE`, this is the first page requested.
#' @param orderby Optional name of a single field by which to sort results.
#' @param sort Optional sort direction. Must be `"ASC"` or `"DESC"` if supplied.
#' @param composite Logical. If `TRUE`, use the composite Advanced Search
#'   endpoint, which returns additional nested detail such as linked resources
#'   and associated units. Defaults to `FALSE`.
#' @param all_pages Logical. If `TRUE`, request pages sequentially starting with
#'   `page` and combine results into one tibble. Defaults to `FALSE`.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A tibble of Advanced Search result items. Page metadata from the
#'   response is stored in the `"page_detail"` attribute. When
#'   `all_pages = TRUE`, `"page_detail"` is a list containing page metadata for
#'   each requested page. When `composite = TRUE`, the returned tibble may
#'   include list-columns such as `linkedResources` and `units`.
#'
#' @examples
#' \dontrun{
#' # Quick Search using the Advanced Search endpoint
#' results <- search_references(
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
#' results <- search_references(
#'   criteria = list(
#'     quickSearch = "Kodiak, goats"
#'   ),
#'   top = 100
#' )
#'
#' # Retrieve all result pages
#' all_results <- search_references(
#'   criteria = list(
#'     quickSearch = "Kodiak, goats"
#'   ),
#'   top = 100,
#'   all_pages = TRUE
#' )
#'
#' # Return composite results with linked resources and units
#' composite_results <- search_references(
#'   criteria = list(
#'     quickSearch = "Kodiak, goats"
#'   ),
#'   composite = TRUE
#' )
#'
#' # Search public records and sort by issue date
#' results <- search_references(
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
#' # Search by reference type. NULL fields are omitted from the request body.
#' reports <- search_references(
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
#' title_results <- search_references(
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
#' date_results <- search_references(
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
#' file_results <- search_references(
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
search_references <- function(
    criteria,
    top = 25,
    page = 1,
    orderby = NULL,
    sort = NULL,
    composite = FALSE,
    all_pages = FALSE,
    secure = FALSE,
    api_key = NULL
) {
  validate_flag(secure)
  validate_flag(composite)
  validate_flag(all_pages)
  validate_whole_number(top, arg = "top")
  validate_whole_number(page, arg = "page")
  
  if (!is.list(criteria) || is.null(names(criteria))) {
    cli::cli_abort(
      "{.arg criteria} must be a named list of Advanced Search criteria."
    )
  }
  
  criteria <- compact_null_values(criteria)
  
  if (length(criteria) == 0) {
    cli::cli_abort(
      "{.arg criteria} must include at least one non-NULL Advanced Search criterion."
    )
  }
  
  if (!is.null(orderby)) {
    validate_string(orderby)
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
  
  page_detail_number <- function(page_detail, fields) {
    for (field in fields) {
      value <- page_detail[[field]]
      
      if (!is.null(value) && length(value) == 1) {
        value <- suppressWarnings(as.numeric(value))
        
        if (!is.na(value)) {
          return(value)
        }
      }
    }
    
    NA_real_
  }
  
  fetch_page <- function(page_number) {
    req <- servcat_request(secure = secure, api_key = api_key)
    
    if (isTRUE(composite)) {
      req <- req |>
        httr2::req_url_path_append("AdvancedSearch", "Composite")
    } else {
      req <- req |>
        httr2::req_url_path_append("AdvancedSearch")
    }
    
    req <- req |>
      httr2::req_url_query(
        top = top,
        page = page_number
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
    } else if (isTRUE(composite)) {
      json_to_composite_tibble(items)
    } else {
      json_to_tibble(items)
    }
    
    page_detail <- if (is.null(response$pageDetail)) {
      list()
    } else {
      response$pageDetail
    }
    
    attr(results, "page_detail") <- page_detail
    
    list(
      results = results,
      page_detail = page_detail,
      item_count = length(items)
    )
  }
  
  current_page <- as.integer(page)
  current <- fetch_page(current_page)
  
  if (!isTRUE(all_pages)) {
    return(current$results)
  }
  
  results <- list(current$results)
  page_details <- list(current$page_detail)
  
  repeat {
    if (current$item_count == 0 || current$item_count < top) {
      break
    }
    
    total_pages <- page_detail_number(
      current$page_detail,
      c("totalPages", "totalPageCount", "pageCount", "pages")
    )
    
    response_page <- page_detail_number(
      current$page_detail,
      c("page", "pageNumber", "currentPage")
    )
    
    if (is.na(response_page)) {
      response_page <- current_page
    }
    
    if (!is.na(total_pages) && response_page >= total_pages) {
      break
    }
    
    current_page <- current_page + 1
    current <- fetch_page(current_page)
    
    page_details <- append(page_details, list(current$page_detail))
    
    if (current$item_count == 0) {
      break
    }
    
    results <- append(results, list(current$results))
  }
  
  results <- dplyr::bind_rows(results)
  
  attr(results, "page_detail") <- list(
    all_pages = TRUE,
    start_page = as.integer(page),
    pages_retrieved = length(results),
    pages = page_details
  )
  
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
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
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
  validate_whole_number(collection_id, arg = "collection_id")
  validate_flag(secure)

  collection_id <- as.integer(collection_id)

  refs_resp <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("SavedCollection", "Composite", collection_id) |>
    httr2::req_headers(
      accept = "application/json"
    ) |>
    httr2::req_perform()

  validate_response(refs_resp)

  httr2::resp_body_json(refs_resp, simplifyVector = FALSE) |>
    json_to_composite_tibble()
}


#' Get the current ServCat service version
#'
#' Retrieves the current ServCat service version from the service metadata
#' endpoint.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key. If omitted, the package API-key
#'   helper is used for secure requests.
#'
#' @returns A length-1 character vector with the current ServCat service
#'   version.
#'
#' @examples
#' \dontrun{
#' # Retrieve the public ServCat service version
#' service_version()
#'
#' # Retrieve the secure ServCat service version
#' service_version(secure = TRUE)
#' }
#'
#' @export
service_version <- function(secure = FALSE, api_key = NULL) {
  validate_flag(secure)

  version_resp <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("ServiceVersion") |>
    httr2::req_perform()

  validate_response(version_resp)

  version <- httr2::resp_body_json(
    version_resp,
    simplifyVector = TRUE
  )

  if (is.character(version) && length(version) == 1) {
    return(version)
  }

  if (is.atomic(version) && length(version) == 1) {
    return(as.character(version))
  }

  if (is.list(version) && length(version) == 1) {
    return(as.character(version[[1]]))
  }

  cli::cli_abort("Could not parse the ServCat service version response.")
}
