#!usr/bin/env Rscript

# this file contains the mnmdb authentication object.

#' Authentication for mnmdb via connection parameters
#'
#' manage authentification storage for connections to mnm databases
#'
#' @details tbd
#'
#' @param folder the structure folder with csv files for all tables
#' @param host the host (IP address or url); default 'localhost'
#' @param port on which the host listens for input; default '5439'
#' @param database name of the database to access
#' @param user username to get connected
#'
#' @examples
#' \dontrun{
#'   auth <- mnmdb::mnmdbAuth(file.path("config_files", "test.conf"))
#' }
#'
mnmdbAuth <- S7::new_class(
  name = "mnmdbAuth",
  properties = list(
    # config_file = S7::class_character
    folder = S7::class_character,
    host = S7::class_character,
    port = S7::class_character,
    database = S7::class_character,
    user = S7::class_character
  ),
  validator = function(self) {
  }
)



#' Authentication for mnmdb via config file
#'
#' @inheritParams mnmdbAuth
#'
#' @param config_file file.path to a config file to load with `configr`
#'
#' @examples
#' \dontrun{
#'   auth <- mnmdb::mnmdbAuth(file.path("config_files", "test.conf"))
#' }
#'
mnmdbAuthConf <- S7::new_class(
  name = "mnmdbAuthConf",
  parent = mnmdbAuth,
  properties = list(
    config_file = S7::class_character
  ),
  validator = function(self) {
    if (isFALSE(file.exists(self@config_file))) {
      return("The config file @config_file does not exist!")
    }
  }
)
