#!usr/bin/env Rscript

# Basic functionality to query a single table from an mnmdb.


#' Query tables from MNE databases.
#'
#' @description
#' This function enables direct query of data from MNE databases.
#'
#' @param conn the mnmdb connection
#' @param table_id the `DBI::Id` of a table
#' @param subselect character vector of fields to select
#' @param ... Not used.
#'
#' @returns tibble or (spatial) data frame
#' @export
#'
query_table <- S7::new_generic("query_table", "conn")


#' The actual query of a table.
#'
#' @rdname query_table
#' @param ... Not used.
#'
S7::method(query_table, mnmdbConnection) <- function(conn, table_id, subselect = NA) {

  is_spatial <- FALSE
  if (is_spatial) {
    # TODO not implemented / requires structure info

    # load and return data
    data <- sf::st_read(
        conn@database_connection,
        layer = table_id,
        geometry_column = "wkb_geometry"
      ) %>%
      dplyr::select(-ogc_fid) %>%
      sf::st_as_sf(crs = 31370)

    sf::st_geometry(data) <- "wkb_geometry"

  } else {

    ## else: non-spatial
    data <- dplyr::tbl(
        conn@database_connection,
        table_id
      ) %>%
      dplyr::collect()

  }

  # data %>% mutate(test =
  #   unlist_keep_na(purrr::map(log_creation, convert_timestamp_to_ms_character))
  # ) %>% pull(test)


  if (isFALSE(is.scalar.na(subselect))) {
    data <- data %>%
      dplyr::select(!!!rlang::syms(subselect))
  }

    # grts_datatype_to_integer() %>%
    # convert_df_datetime_types_to_character() %>%
  data %>%
    dplyr::as_tibble() %>%
    return()

}
