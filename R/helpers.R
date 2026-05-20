## package-level globals ----

.pkgglobalenv <- new.env(parent = emptyenv())

assign(
  "servcat_public_api",
  "https://iris.fws.gov/APPS/ServCatServices/servcat/v4/rest",
  envir = .pkgglobalenv
)

assign(
  "servcat_secure_api",
  "https://iris.fws.gov/APPS/ServCatServices/servcat-secure/v4/rest",
  envir = .pkgglobalenv
)

utils::globalVariables(c(".data"))


#' Remove NULL values from a nested list
#'
#' Recursively removes `NULL` values from a list before sending it as a JSON
#' request body. Empty child lists are retained.
#'
#' @param x A list or other object.
#'
#' @returns `x` with `NULL` list elements removed.
#' @keywords internal
compact_null_values <- function(x) {
  if (!is.list(x)) {
    return(x)
  }
  
  x <- lapply(x, compact_null_values)
  
  x[!vapply(x, is.null, logical(1))]
}


#' Validate a TRUE/FALSE argument
#'
#' @param x Value to validate.
#' @param arg Used to generate helpful error messages.
#' @param call Calling environment.
#'
#' @returns `NULL`, invisibly.
#' @keywords internal
validate_flag <- function(
    x,
    arg = rlang::caller_arg(x),
    call = rlang::caller_env()
) {
  if (!is.logical(x) || length(x) != 1 || is.na(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be logical (`TRUE` or `FALSE`).",
      call = call
    )
  }

  invisible(NULL)
}


#' Validate a positive whole-number argument
#'
#' @param x Value to validate.
#' @param arg Used to generate helpful error messages.
#' @param multiple_ok Logical. Are multiple values allowed?
#' @param min Minimum allowed value.
#' @param call Calling environment.
#'
#' @returns `NULL`, invisibly.
#' @keywords internal
validate_whole_number <- function(
    x,
    arg = rlang::caller_arg(x),
    multiple_ok = FALSE,
    min = 1,
    call = rlang::caller_env()
) {
  if (missing(x) || length(x) == 0) {
    cli::cli_abort("{.arg {arg}} must be supplied.", call = call)
  }

  if (!multiple_ok && length(x) != 1) {
    cli::cli_abort("{.arg {arg}} must be a single value.", call = call)
  }

  if (
    !is.numeric(x) ||
      anyNA(x) ||
      any(!is.finite(x)) ||
      any(x != floor(x)) ||
      any(x < min)
  ) {
    cli::cli_abort(
      "{.arg {arg}} must be positive whole number(s).",
      call = call
    )
  }

  invisible(NULL)
}


#' Validate a single non-empty character argument
#'
#' @param x Value to validate.
#' @param arg Used to generate helpful error messages.
#' @param call Calling environment.
#'
#' @returns `NULL`, invisibly.
#' @keywords internal
validate_string <- function(
    x,
    arg = rlang::caller_arg(x),
    call = rlang::caller_env()
) {
  if (!is.character(x) || length(x) != 1 || is.na(x) || !nzchar(x)) {
    cli::cli_abort(
      "{.arg {arg}} must be a single non-empty character string.",
      call = call
    )
  }

  invisible(NULL)
}


#' Validate a ServCat reference ID
#'
#' @param reference_id ServCat reference ID or IDs.
#' @param multiple_ok Logical. Are multiple IDs allowed?
#' @param arg Used to generate helpful error messages.
#' @param call Calling environment.
#'
#' @returns `NULL`, invisibly.
#' @keywords internal
validate_reference_id <- function(
    reference_id,
    multiple_ok = FALSE,
    arg = rlang::caller_arg(reference_id),
    call = rlang::caller_env()
) {
  validate_whole_number(
    x = reference_id,
    arg = arg,
    multiple_ok = multiple_ok,
    min = 1,
    call = call
  )
}


#' Collapse reference IDs for the Profile endpoint
#'
#' @param reference_ids Numeric vector of reference IDs.
#'
#' @returns A length-1 character vector.
#' @keywords internal
collapse_reference_ids <- function(reference_ids) {
  paste(unique(reference_ids), collapse = ",")
}


#' Chunk reference IDs for Profile requests
#'
#' @param reference_ids Numeric vector of reference IDs.
#' @param chunk_size Maximum number of IDs per request.
#'
#' @returns A list of numeric vectors.
#' @keywords internal
chunk_reference_ids <- function(reference_ids, chunk_size = 25) {
  split(reference_ids, ceiling(seq_along(reference_ids) / chunk_size))
}


#' Convert nested lists in a profile to vectors
#'
#' @param parent_list A ServCat profile record.
#' @param child_list_names Element names to simplify.
#'
#' @returns A modified list.
#' @keywords internal
lists_to_vectors <- function(parent_list, child_list_names) {
  for (child_list in child_list_names) {
    if (!is.null(parent_list[[child_list]])) {
      parent_list[[child_list]] <- unlist(parent_list[[child_list]], use.names = FALSE)
    }
  }

  parent_list
}


#' Convert nested lists in a profile to tibbles
#'
#' @param parent_list A ServCat profile record.
#' @param child_list_names Element names to convert.
#'
#' @returns A modified list.
#' @keywords internal
lists_to_tibbles <- function(parent_list, child_list_names) {
  for (child_list in child_list_names) {
    if (!is.null(parent_list[[child_list]])) {
      parent_list[[child_list]] <- dplyr::bind_rows(parent_list[[child_list]])
    }
  }

  parent_list
}


#' Convert JSON records to a tibble
#'
#' @param x Parsed JSON object from a ServCat response.
#' @param rename_key Logical. Rename a `key` column to `code`?
#'
#' @returns A tibble.
#' @keywords internal
json_to_tibble <- function(x, rename_key = FALSE) {
  if (length(x) == 0) {
    return(tibble::tibble())
  }

  if (!is.null(names(x))) {
    x <- list(x)
  }

  out <- suppressWarnings(
    data.table::rbindlist(x, use.names = TRUE, fill = TRUE)
  ) |>
    tibble::as_tibble()

  if (rename_key && "key" %in% names(out)) {
    out <- dplyr::rename(out, code = .data$key)
  }

  out
}


#' Convert composite JSON records to a tibble
#'
#' @param x Parsed JSON object from a ServCat composite endpoint.
#'
#' @returns A tibble. Nested objects are preserved as list-columns.
#' @keywords internal
json_to_composite_tibble <- function(x) {
  if (length(x) == 0) {
    return(tibble::tibble())
  }

  if (!is.null(names(x))) {
    x <- list(x)
  }

  rows <- lapply(x, function(record) {
    record <- lapply(record, function(value) {
      if (is.null(value)) {
        return(NA)
      }

      if (is.atomic(value) && length(value) <= 1) {
        return(value)
      }

      list(value)
    })

    tibble::as_tibble(record)
  })

  dplyr::bind_rows(rows)
}


#' Get a ServCat fixed list
#'
#' @param endpoint Fixed-list endpoint name.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#' @param rename_key Logical. Rename a `key` column to `code`?
#'
#' @returns A tibble.
#' @keywords internal
get_fixed_list <- function(
    endpoint,
    secure = FALSE,
    api_key = NULL,
    rename_key = TRUE
) {
  validate_string(endpoint)
  validate_flag(secure)

  resp <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("FixedList", endpoint) |>
    httr2::req_perform()

  validate_response(resp)

  httr2::resp_body_json(resp, simplifyVector = FALSE) |>
    json_to_tibble(rename_key = rename_key)
}


#' Get the base URL for the ServCat API
#'
#' @param secure Logical. Use the secure ServCat API?
#'
#' @returns A length-1 character vector.
#' @keywords internal
base_url <- function(secure = FALSE) {
  validate_flag(secure)

  dplyr::case_when(
    secure ~ get("servcat_secure_api", envir = .pkgglobalenv),
    !secure ~ get("servcat_public_api", envir = .pkgglobalenv)
  )
}


#' Retrieve secure ServCat API key
#'
#' @param env_var Environment variable name.
#'
#' @returns A length-1 character vector.
#' @keywords internal
get_api_key <- function(env_var = "SERVCAT_API_KEY") {
  key <- Sys.getenv(env_var, unset = "")

  if (identical(key, "")) {
    cli::cli_abort(
      "Environment variable {.val {env_var}} is not set."
    )
  }

  key
}


#' Build a ServCat request
#'
#' @param secure Logical. Use the secure API?
#' @param suppress_errors Logical. Suppress HTTP errors so they can be handled
#'   by `validate_response()`.
#' @param api_key Optional API key. If omitted for secure requests, the value is
#'   read from `SERVCAT_API_KEY`.
#'
#' @returns An `httr2_request` object.
#' @keywords internal
servcat_request <- function(
    secure = FALSE,
    suppress_errors = TRUE,
    api_key = NULL
) {
  validate_flag(secure)
  validate_flag(suppress_errors)
  
  req <- httr2::request(base_url(secure = secure)) |>
    httr2::req_user_agent("servcat") |>
    httr2::req_headers(accept = "application/json") |>
    httr2::req_timeout(60) |>
    httr2::req_retry(max_tries = 3)
  
  if (secure) {
    api_key <- rlang::`%||%`(api_key, get_api_key())
    validate_string(api_key, arg = "api_key")
    
    req <- req |>
      httr2::req_headers(`X-API-KEY` = api_key)
  }
  
  if (suppress_errors) {
    req <- req |>
      httr2::req_error(is_error = \(resp) FALSE)
  }
  
  req
}


#' Validate a ServCat API response
#'
#' @param resp An `httr2_response`.
#' @param nice_msg_400 Optional message for 4xx errors.
#' @param nice_msg_500 Optional message for 5xx errors.
#' @param call Calling environment.
#'
#' @returns `NULL`, invisibly.
#' @keywords internal
validate_response <- function(
    resp,
    nice_msg_400,
    nice_msg_500,
    call = rlang::caller_env()
) {
  if (httr2::resp_is_error(resp)) {
    if (missing(nice_msg_400)) {
      nice_msg_400 <- c(
        "i" = "There is a problem with the API request. Check reference IDs, search terms, and filters for typos.",
        "i" = "If you are using the secure API, verify that your API key is set and valid."
      )
    }
    
    if (missing(nice_msg_500)) {
      nice_msg_500 <- c(
        "i" = "The ServCat service returned a server error. Try again later or confirm the endpoint is available."
      )
    }
    
    status_num <- httr2::resp_status(resp)
    status_desc <- httr2::resp_status_desc(resp)
    
    nice_msg <- if (floor(status_num / 100) == 5) {
      nice_msg_500
    } else {
      nice_msg_400
    }
    
    api_message <- response_error_message(resp)
    
    msg <- c(
      "HTTP {status_num}: {status_desc}",
      nice_msg
    )
    
    if (!is.null(api_message)) {
      msg <- c(
        msg,
        "x" = "API response: {.field api_message}"
      )
    }
    
    cli::cli_abort(msg, call = call)
  }
  
  invisible(NULL)
}


#' Sanitize a file name from ServCat metadata
#'
#' @param file_name File name from the ServCat API.
#' @param fallback Fallback file name.
#'
#' @returns A length-1 character vector.
#' @keywords internal
sanitize_file_name <- function(file_name, fallback) {
  if (length(file_name) == 0 || is.na(file_name) || !nzchar(file_name)) {
    file_name <- fallback
  }

  file_name <- basename(as.character(file_name)[[1]])
  file_name <- gsub("[[:cntrl:]/\\\\:*?\"<>|]+", "_", file_name, perl = TRUE)

  if (!nzchar(file_name) || file_name %in% c(".", "..")) {
    file_name <- fallback
  }

  file_name
}


#' Build a safe output path for a downloaded ServCat file
#'
#' @param path Output directory.
#' @param file_name File name from the ServCat API.
#' @param resource_id ServCat resource ID.
#' @param overwrite Logical. Overwrite existing files?
#'
#' @returns A length-1 character vector.
#' @keywords internal
build_download_path <- function(path, file_name, resource_id, overwrite = FALSE) {
  validate_flag(overwrite)

  fallback <- paste0(resource_id, ".bin")
  file_name <- sanitize_file_name(file_name, fallback = fallback)
  output_path <- file.path(path, file_name)

  if (overwrite || !file.exists(output_path)) {
    return(output_path)
  }

  ext <- tools::file_ext(file_name)
  stem <- if (nzchar(ext)) {
    sub(paste0("\\.", ext, "$"), "", file_name)
  } else {
    file_name
  }

  i <- 0
  repeat {
    suffix <- if (i == 0) {
      as.character(resource_id)
    } else {
      paste(resource_id, i, sep = "_")
    }

    candidate_name <- if (nzchar(ext)) {
      paste0(stem, "_", suffix, ".", ext)
    } else {
      paste0(stem, "_", suffix)
    }

    candidate_path <- file.path(path, candidate_name)

    if (!file.exists(candidate_path)) {
      return(candidate_path)
    }

    i <- i + 1
  }
}


#' Retrieve a batch of ServCat reference profiles
#'
#' @param reference_ids Numeric vector of up to 25 ServCat reference IDs.
#' @param secure Logical. Use the secure API?
#' @param api_key Optional secure API key.
#'
#' @returns A named list of ServCat profile records. Field names returned by the
#'   API are preserved.
#' @keywords internal
get_reference_profiles_batch <- function(
    reference_ids,
    secure = FALSE,
    api_key = NULL
) {
  req <- servcat_request(secure = secure, api_key = api_key) |>
    httr2::req_url_path_append("Profile") |>
    httr2::req_url_query(q = collapse_reference_ids(reference_ids)) |>
    httr2::req_perform()
  
  validate_response(req)
  
  response <- httr2::resp_body_json(req, simplifyVector = FALSE)
  
  to_vectors <- c("keywords", "subjects")
  to_tibbles <- c("taxa", "units", "contentProducerUnits", "filesAndLinks")
  
  response <- lapply(response, simplify_reference_profile)
  
  ids <- vapply(
    response,
    function(ref) rlang::`%||%`(ref$referenceId, NA_real_),
    numeric(1)
  )
  
  names(response) <- as.character(ids)
  
  response
}

#' Clean an error message for use in returned data
#'
#' Removes ANSI styling and collapses whitespace so condition messages can be
#' stored cleanly in tibble columns.
#'
#' @param x A condition object or character string.
#'
#' @returns A clean character scalar.
#' @keywords internal
clean_error_message <- function(x) {
  msg <- if (inherits(x, "condition")) {
    conditionMessage(x)
  } else {
    as.character(x)
  }
  
  msg <- cli::ansi_strip(msg)
  msg <- stringr::str_replace_all(msg, "\n+", " ")
  msg <- stringr::str_squish(msg)
  
  # Remove common cli bullet prefixes after ANSI stripping.
  msg <- stringr::str_replace(msg, "^!\\s*", "")
  msg <- stringr::str_replace(msg, "^x\\s*", "")
  msg <- stringr::str_replace(msg, "^i\\s*", "")
  
  msg
}


#' Build a clean restricted-resource message
#'
#' @param reference_id A ServCat reference ID.
#' @param resource_id Optional ServCat resource ID.
#' @param secure Logical. Is the secure API being used?
#'
#' @returns A clean character scalar.
#' @keywords internal
restricted_resource_error <- function(reference_id, resource_id = NULL, secure = FALSE) {
  resource_part <- if (is.null(resource_id) || is.na(resource_id)) {
    paste0("file metadata for reference ", reference_id)
  } else {
    paste0("file resource ", resource_id, " on reference ", reference_id)
  }
  
  if (isTRUE(secure)) {
    return(paste0(
      "ServCat denied access to ", resource_part,
      ". You are using the secure API, so verify that your API key is valid ",
      "and has permission to access this internal or restricted resource."
    ))
  }
  
  paste0(
    "ServCat denied access to ", resource_part,
    ". This file may be internal or otherwise restricted. ",
    "Retry with secure = TRUE and make sure SERVCAT_API_KEY is set, ",
    "or pass api_key directly."
  )
}


#' Parse a ServCat ReferenceProfile response
#'
#' Parses an `httr2` response whose body contains a single ServCat
#' `ReferenceProfile` object.
#'
#' This helper is intended for secure write endpoints that return a full
#' Reference profile, such as `/rest/MetadataUpload`. It preserves API field
#' names and applies the same light profile simplification used elsewhere in
#' the package: selected scalar list fields are converted to character vectors,
#' and selected repeated object fields are converted to tibbles.
#'
#' This function assumes the HTTP response has already been checked with
#' `validate_response()`. It is responsible only for parsing and shaping the
#' response body.
#'
#' @param resp An `httr2_response` object returned by a ServCat endpoint whose
#'   response body is a single `ReferenceProfile`.
#' @param simplify Logical. If `TRUE`, simplify selected nested profile fields
#'   to vectors or tibbles. If `FALSE`, return the parsed JSON list without
#'   additional reshaping.
#' @param call Calling environment used for error reporting.
#'
#' @returns A named list representing a ServCat `ReferenceProfile`. When
#'   `simplify = TRUE`, `keywords` and `subjects` are simplified to character
#'   vectors where present, and `taxa`, `units`, `contentProducerUnits`, and
#'   `filesAndLinks` are simplified to tibbles where present.
#'
#' @keywords internal
#' @noRd
parse_reference_profile_response <- function(
    resp,
    simplify = TRUE,
    call = rlang::caller_env()
) {
  validate_flag(simplify, call = call)
  
  if (!inherits(resp, "httr2_response")) {
    cli::cli_abort(
      "{.arg resp} must be an {.cls httr2_response} object.",
      call = call
    )
  }
  
  profile <- httr2::resp_body_json(
    resp,
    simplifyVector = FALSE
  )
  
  if (!is.list(profile) || length(profile) == 0 || is.null(names(profile))) {
    cli::cli_abort(
      "Could not parse the ServCat response as a single ReferenceProfile object.",
      call = call
    )
  }
  
  profile_fields <- c(
    "referenceId",
    "referenceType",
    "citation",
    "visibility",
    "lifecycle",
    "bibliography"
  )
  
  if (!any(profile_fields %in% names(profile))) {
    cli::cli_abort(
      c(
        "The ServCat response does not look like a ReferenceProfile object.",
        "i" = "Expected at least one of: {.field {profile_fields}}."
      ),
      call = call
    )
  }
  
  if (!isTRUE(simplify)) {
    return(profile)
  }
  
  simplify_reference_profile(profile)
  
  to_vectors <- c(
    "keywords",
    "subjects"
  )
  
  to_tibbles <- c(
    "taxa",
    "units",
    "contentProducerUnits",
    "filesAndLinks"
  )
  
  profile <- lists_to_vectors(profile, to_vectors)
  profile <- lists_to_tibbles(profile, to_tibbles)
  
  profile
}


#' Extract a useful error message from a ServCat API response
#'
#' Attempts to extract a concise server-supplied error message from an
#' `httr2_response`. ServCat error responses may be JSON or plain text, so this
#' helper first looks for common JSON error fields and then falls back to the
#' response body as text.
#'
#' @param resp An `httr2_response` object.
#'
#' @returns A single character string, or `NULL` if no response message can be
#'   extracted.
#'
#' @keywords internal
response_error_message <- function(resp) {
  if (!inherits(resp, "httr2_response")) {
    return(NULL)
  }
  
  parsed <- tryCatch(
    httr2::resp_body_json(resp, simplifyVector = FALSE),
    error = function(e) NULL
  )
  
  if (is.list(parsed) && length(parsed) > 0) {
    candidates <- c(
      "message",
      "Message",
      "error",
      "Error",
      "detail",
      "Detail",
      "title",
      "Title",
      "exceptionMessage",
      "ExceptionMessage"
    )
    
    for (field in candidates) {
      value <- parsed[[field]]
      
      if (is.character(value) && length(value) > 0 && nzchar(value[[1]])) {
        return(clean_error_message(value[[1]]))
      }
    }
    
    if (!is.null(parsed$ModelState) && is.list(parsed$ModelState)) {
      model_state <- unlist(parsed$ModelState, use.names = FALSE)
      
      if (length(model_state) > 0) {
        model_state <- model_state[!is.na(model_state) & nzchar(model_state)]
        
        if (length(model_state) > 0) {
          return(clean_error_message(paste(model_state, collapse = " ")))
        }
      }
    }
  }
  
  text <- tryCatch(
    httr2::resp_body_string(resp),
    error = function(e) NULL
  )
  
  if (is.character(text) && length(text) > 0 && nzchar(text[[1]])) {
    return(clean_error_message(text[[1]]))
  }
  
  NULL
}


#' Simplify selected fields in a ServCat ReferenceProfile
#'
#' Converts selected nested profile fields to simpler R objects while preserving
#' API field names.
#'
#' @param profile A named list representing a ServCat ReferenceProfile.
#'
#' @returns A modified ReferenceProfile list.
#'
#' @keywords internal
simplify_reference_profile <- function(profile) {
  to_vectors <- c(
    "keywords",
    "subjects"
  )
  
  to_tibbles <- c(
    "taxa",
    "units",
    "contentProducerUnits",
    "filesAndLinks"
  )
  
  profile <- lists_to_vectors(profile, to_vectors)
  profile <- lists_to_tibbles(profile, to_tibbles)
  
  profile
}