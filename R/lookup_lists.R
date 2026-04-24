#' Get valid ServCat access constraint text
#'
#' Retrieves the fixed list of access constraint text used when setting
#' permissions and constraints for a ServCat reference.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A tibble with access constraint metadata.
#' @keywords internal
get_access_constraints <- function(secure = FALSE, api_key = NULL) {
  validate_flag(secure)
  
  constraints <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", "AccessConstraints") |>
    httr2::req_perform()
  
  validate_response(constraints)
  
  constraints <- httr2::resp_body_json(
    constraints,
    simplifyVector = FALSE
  )
  
  if (length(constraints) == 0) {
    return(tibble::tibble())
  }
  
  suppressWarnings(
    data.table::rbindlist(constraints, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble() |>
    dplyr::rename(code = .data$key)
}


#' Get valid ServCat date precision choices
#'
#' Retrieves the fixed list of DatePrecision choices used for issued dates and
#' content begin/end dates.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A tibble with date precision choices.
#' @keywords internal
get_date_precisions <- function(secure = FALSE, api_key = NULL) {
  validate_flag(secure)
  
  date_precisions <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", "DatePrecisions") |>
    httr2::req_perform()
  
  validate_response(date_precisions)
  
  date_precisions <- httr2::resp_body_json(
    date_precisions,
    simplifyVector = FALSE
  )
  
  if (length(date_precisions) == 0) {
    return(tibble::tibble())
  }
  
  suppressWarnings(
    data.table::rbindlist(date_precisions, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble() |>
    dplyr::rename(code = .data$key)
}


#' Get valid ServCat file processing tags
#'
#' Retrieves the fixed list of tags used when designating certain digital file
#' types for offline processing.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A tibble with file processing tag choices.
#' @keywords internal
get_file_processing_tags <- function(secure = FALSE, api_key = NULL) {
  validate_flag(secure)
  
  tags <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", "FileProcessingTags") |>
    httr2::req_perform()
  
  validate_response(tags)
  
  tags <- httr2::resp_body_json(
    tags,
    simplifyVector = FALSE
  )
  
  if (length(tags) == 0) {
    return(tibble::tibble())
  }
  
  suppressWarnings(
    data.table::rbindlist(tags, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble() |>
    dplyr::rename(code = .data$key)
}


#' Get valid ServCat reference type groups
#'
#' Retrieves the fixed list of Reference Type Groups used as an Advanced Search
#' option in ServCat.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A tibble with reference type group choices.
#' @keywords internal
get_reference_type_groups <- function(secure = FALSE, api_key = NULL) {
  validate_flag(secure)
  
  reference_type_groups <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", "ReferenceTypeGroups") |>
    httr2::req_perform()
  
  validate_response(reference_type_groups)
  
  reference_type_groups <- httr2::resp_body_json(
    reference_type_groups,
    simplifyVector = FALSE
  )
  
  if (length(reference_type_groups) == 0) {
    return(tibble::tibble())
  }
  
  suppressWarnings(
    data.table::rbindlist(reference_type_groups, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble() |>
    dplyr::rename(code = .data$key)
}


#' Get valid ServCat reference types
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key
#'
#' @returns A tibble with ServCat reference type metadata
#' @keywords internal
get_reference_types <- function(secure = FALSE, api_key = NULL) {
  ref_types_resp <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", "ReferenceTypes") |>
    httr2::req_perform()
  
  validate_response(ref_types_resp)
  
  ref_types <- httr2::resp_body_json(
    ref_types_resp,
    simplifyVector = FALSE
  ) |>
    dplyr::bind_rows() |>
    dplyr::rename(code = key)
  
  ref_groups_resp <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", "ReferenceTypeGroups") |>
    httr2::req_perform()
  
  validate_response(ref_groups_resp)
  
  ref_group_map <- httr2::resp_body_json(
    ref_groups_resp,
    simplifyVector = FALSE
  ) |>
    purrr::map_dfr(\(group) {
      tibble::tibble(
        ref_group_code = group$key,
        code = stringr::str_split(group$description %||% "", ",\\s*")[[1]]
      )
    }) |>
    dplyr::filter(.data$code != "")
  
  ref_types |>
    dplyr::left_join(ref_group_map, by = "code") |>
    dplyr::relocate(.data$ref_group_code, .after = .data$code) |>
    dplyr::arrange(.data$ref_group_code, .data$code) |>
    tibble::as_tibble()
}


#' Get ServCat contact display names by reference type
#'
#' Retrieves the display names for the `Contacts1`, `Contacts2`, and
#' `Contacts3` fields for a given ServCat reference type.
#'
#' @param reference_type A single ServCat reference type, such as `"Brochure"`.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A tibble with contact field display names.
#' @keywords internal
get_contact_display_names <- function(
    reference_type,
    secure = FALSE,
    api_key = NULL
) {
  validate_flag(secure)
  
  if (
    !is.character(reference_type) ||
    length(reference_type) != 1 ||
    is.na(reference_type) ||
    !nzchar(reference_type)
  ) {
    cli::cli_abort(
      "{.arg reference_type} must be a single non-empty character string."
    )
  }
  
  contacts <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", reference_type, "Contacts") |>
    httr2::req_perform()
  
  validate_response(
    contacts,
    nice_msg_400 = c(
      "i" = "Check that {.arg reference_type} is a valid ServCat reference type, such as {.val Brochure}."
    )
  )
  
  contacts <- httr2::resp_body_json(
    contacts,
    simplifyVector = FALSE
  )
  
  if (length(contacts) == 0) {
    return(tibble::tibble())
  }
  
  contacts <- suppressWarnings(
    data.table::rbindlist(contacts, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble()
  
  if ("key" %in% names(contacts)) {
    contacts <- contacts |>
      dplyr::rename(code = .data$key)
  }
  
  contacts
}


#' Get ServCat publisher display name by reference type
#'
#' Retrieves the display name for the `Publisher` field for a given ServCat
#' reference type.
#'
#' @param reference_type A single ServCat reference type, such as `"Brochure"`.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A tibble with the publisher field display name.
#' @keywords internal
get_publisher_display_name <- function(
    reference_type,
    secure = FALSE,
    api_key = NULL
) {
  validate_flag(secure)
  
  if (
    !is.character(reference_type) ||
    length(reference_type) != 1 ||
    is.na(reference_type) ||
    !nzchar(reference_type)
  ) {
    cli::cli_abort(
      "{.arg reference_type} must be a single non-empty character string."
    )
  }
  
  publisher <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", reference_type, "Publisher") |>
    httr2::req_perform()
  
  validate_response(
    publisher,
    nice_msg_400 = c(
      "i" = "Check that {.arg reference_type} is a valid ServCat reference type, such as {.val Brochure}."
    )
  )
  
  publisher <- httr2::resp_body_json(
    publisher,
    simplifyVector = FALSE
  )
  
  if (length(publisher) == 0) {
    return(tibble::tibble())
  }
  
  if (!is.null(names(publisher))) {
    publisher <- list(publisher)
  }
  
  publisher <- suppressWarnings(
    data.table::rbindlist(publisher, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble()
  
  if ("key" %in% names(publisher)) {
    publisher <- publisher |>
      dplyr::rename(code = .data$key)
  }
  
  publisher
}


#' Get ServCat size display names by reference type
#'
#' Retrieves the display names for the `Size1`, `Size2`, and `Size3` fields
#' for a given ServCat reference type.
#'
#' @param reference_type A single ServCat reference type, such as `"Brochure"`.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A tibble with size field display names.
#' @keywords internal
get_size_display_names <- function(
    reference_type,
    secure = FALSE,
    api_key = NULL
) {
  validate_flag(secure)
  
  if (
    !is.character(reference_type) ||
    length(reference_type) != 1 ||
    is.na(reference_type) ||
    !nzchar(reference_type)
  ) {
    cli::cli_abort(
      "{.arg reference_type} must be a single non-empty character string."
    )
  }
  
  sizes <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", reference_type, "Sizes") |>
    httr2::req_perform()
  
  validate_response(
    sizes,
    nice_msg_400 = c(
      "i" = "Check that {.arg reference_type} is a valid ServCat reference type, such as {.val Brochure}."
    )
  )
  
  sizes <- httr2::resp_body_json(
    sizes,
    simplifyVector = FALSE
  )
  
  if (length(sizes) == 0) {
    return(tibble::tibble())
  }
  
  sizes <- suppressWarnings(
    data.table::rbindlist(sizes, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble()
  
  if ("key" %in% names(sizes)) {
    sizes <- sizes |>
      dplyr::rename(code = .data$key)
  }
  
  sizes
}


#' Get valid ServCat subject categories
#'
#' Retrieves the fixed list of Subject Categories used on the Keywords and
#' Category tab in ServCat.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A tibble with subject category choices.
#' @keywords internal
get_subject_categories <- function(secure = FALSE, api_key = NULL) {
  validate_flag(secure)
  
  subject_categories <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", "SubjectCategories") |>
    httr2::req_perform()
  
  validate_response(subject_categories)
  
  subject_categories <- httr2::resp_body_json(
    subject_categories,
    simplifyVector = FALSE
  )
  
  if (length(subject_categories) == 0) {
    return(tibble::tibble())
  }
  
  subject_categories <- suppressWarnings(
    data.table::rbindlist(subject_categories, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble()
  
  if ("key" %in% names(subject_categories)) {
    subject_categories <- subject_categories |>
      dplyr::rename(code = .data$key)
  }
  
  subject_categories
}


#' Get valid ServCat web service types
#'
#' Retrieves the fixed list of Web Service, or Linked Resource, types used by
#' ServCat.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A tibble with web service type choices.
#' @keywords internal
get_web_service_types <- function(secure = FALSE, api_key = NULL) {
  validate_flag(secure)
  
  web_service_types <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", "WebServiceTypes") |>
    httr2::req_perform()
  
  validate_response(web_service_types)
  
  web_service_types <- httr2::resp_body_json(
    web_service_types,
    simplifyVector = FALSE
  )
  
  if (length(web_service_types) == 0) {
    return(tibble::tibble())
  }
  
  web_service_types <- suppressWarnings(
    data.table::rbindlist(web_service_types, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble()
  
  if ("key" %in% names(web_service_types)) {
    web_service_types <- web_service_types |>
      dplyr::rename(code = .data$key)
  }
  
  web_service_types
}


#' Get the current ServCat application version
#'
#' Retrieves the current ServCat application version from the service metadata
#' endpoint.
#'
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A length-1 character vector with the current ServCat application
#'   version.
#' @keywords internal
get_service_version <- function(secure = FALSE, api_key = NULL) {
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

