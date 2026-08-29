#!usr/bin/env Rscript

# this file contains the mnmdb authentication object.

#' Authentication for mnmdb via connection parameters
#'
#' manage authentification storage for connections to mnm databases
#'
#' @details tbd
#'
#' @param folder the structure folder with csv files for all tables
#' @param host the host (IP address or url); default '127.0.0.1'
#' @param port on which the host listens for input; default '5432'
#' @param database name of the database to access
#' @param user username to get connected
#' @param password password to connect; NA if .pgpass is used
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
    host = S7::new_property(
      class = S7::class_character,
      default = "127.0.0.1"
    ),
    port = S7::new_property(
      class = S7::class_integer | S7::class_character,
      default = "5432"
    ),
    database = S7::class_character,
    user = S7::class_character,
    password = S7::new_property(S7::class_character | NULL, default = NULL)
  ),
  constructor = function(...) {
    # TODO set defaults, overwrite by config, overwrite by user input
    # Then write password to keyring
    params <- list(...)

    # remove password so that it does not retain in memory
    params[["password"]] <- NULL
    print(params)

    return(
      S7::new_object(`mnmdbAuth`,
        folder = params$folder,
        host = params$host,
        port = params$port,
        database = params$database,
        user = params$user,
        password = NULL
      )
    )

    # return(do.call("S7::new_object", c(list(`mnmdbAuth`), params)))
  }
)


# require_pkgs(c("configr"), quietly = TRUE)
# MNMDatabaseConnection.R // connect_database_configfile
# config <- configr::read.config(file = config_filepath)[[1]]

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
  constructor = function(config_file, ...) {
    # TODO set defaults, overwrite by config, overwrite by user input

    params <- list(...)

    # remove password so that it does not retain in memory
    params[["password"]] <- NULL
    print(params)

    return(
      S7::new_object(`mnmdbAuthConf`,
        config_file = config_file,
        folder = ".", #params$folder,
        host = "127.0.0.1", #params$host,
        port = "5432", #params$port,
        database = "sandbox", #params$database,
        user = "user", #params$user,
        password = NULL
      )
    )
  },
  validator = function(self) {
    if (isFALSE(is.character(self@config_file))) {
      return("The config file argument @config_file must be a character.")
    }
    if (isFALSE(file.exists(self@config_file))) {
      return(glue::glue("The config file '{self@config_file}' does not exist!"))
    }
  }
)

# props(x) <- list(name1 = val1, name2 = val2) modifies an existing object by setting multiple properties simultaneously.


#' generic for description of database auth
describe <- S7::new_generic("describe", "auth")
S7::method(describe, mnmdbAuth) <- function(auth) {
  paste0(
    auth@user, " @ ",
    auth@host, ":", auth@port,
    " -d ", auth@database
  )
}
