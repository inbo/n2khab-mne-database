#!usr/bin/env Rscript

# If you want to learn how the connection to an MNM Database is managed, 
# this is the file-to-be.


#' MNE Database Connection Object.
#'
#' Given an authentication for login, this database object is supposed
#' to facilitate all interactions with an actual database.
#'
#' @param auth an mnmdbAuth object which stores authentication
#'
#' @examples
#' \dontrun{
#'   test_auth <- mnmdbAuth(
#'     user = "guest",
#'     database = "sandbox"
#'   )
#'   mnmdbconn <- mnmdbConnection(auth <- test_auth)
#'   mnmdbconn <- mnmdbconn |> connect()
#'   # dplyr::tbl(mnmdbconn@database_connection, DBI::Id("test", "mtcars"))
#' }
#'
mnmdbConnection <- S7::new_class(
  name = "mnmdbConnection",
  properties = list(
    auth = S7::new_property(S7::class_any, default = NULL),
    database_connection = S7::new_property(S7::class_any, default = NULL),
    is_connected = S7::new_property(S7::class_logical, default = FALSE)
  ),
  validator = function(self) {
    if (
      isFALSE(S7::check_is_S7(self@auth, class = mnmdbAuth))
      && isFALSE(S7::check_is_S7(self@auth, class = mnmdbAuthConf))
    ) {
      return("Authentication object @auth required to connect to an MNE database.")
    }
  }
)

#' description of database connection
S7::method(describe, mnmdbConnection) <- function(x) {
  # unwrap
  conn <- x
  auth <- conn@auth

  connected <- if (conn@is_connected) "(connected)" else "(not connected)"
  paste0(
    "Database connection to ",
    auth@user, " @ ",
    auth@host, ":", auth@port,
    " -d ", auth@database,
    " ", connected
  )

}


#' generic method for database connection
connect <- S7::new_generic("connect", "conn")

#' Connect a mnmdbConnection object to the actual database using `auth`.
#'
#' @details This function can be used in a pipe:
#'          it receives and returns a mnmdbConnection.
#'
#' @param conn a mnmdbConnection connection to be connected
#' @returns mnmdbConnection
#'
S7::method(connect, mnmdbConnection) <- function(conn) {


  # shortcut for the already connected
  if (isFALSE(is.null(conn@database_connection))) {
    if (DBI::dbIsValid(database_connection)) {
      return(conn)
    }
  }

  auth <- conn@auth # shortcut

  # for orientation
  db_label <- sprintf("%s@%s/%s", auth@user, auth@host, auth@database)


  # connect to database
  tryCatch({
    if (auth@connect_passwordless) {

      database_connection <- DBI::dbConnect(
        RPostgres::Postgres(),
        dbname = auth@database,
        host   = auth@host,
        port   = auth@port,
        user   = auth@user
      )
    } else {
      # get password from keyring
      password <- keyring::key_get(
        keyring = auth@keyring_label,
        service = "mnmdb_credentials",
        username = auth@user
      )

      # connect with password
      database_connection <- DBI::dbConnect(
        RPostgres::Postgres(),
        dbname = auth@database,
        host   = auth@host,
        port   = auth@port,
        user   = auth@user,
        password = password
      )
      # remove the config: we do not want to expose credentials further
      # down in this notebook
      rm(password)
    }
  },
  error = function(wrnmsg) {
    message(glue::glue("error in connecting {db_label}:"))
    message(wrnmsg)
  })

  # register disconnect for finalization
  # https://stackoverflow.com/a/41179916
  reg.finalizer(
    .GlobalEnv,
    function(e) {
      if (DBI::dbIsValid(database_connection)) {
        DBI::dbDisconnect(database_connection)
        message(sprintf(
          "MNE database connection %s gracefully disconnected.",
          db_label
        ))
      }
    },
    onexit = TRUE
  )

  conn@database_connection <- database_connection

  return(invisible(conn))

} # /connect(mnmdbConnection)
