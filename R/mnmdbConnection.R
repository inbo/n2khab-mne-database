#!usr/bin/env Rscript

# If you want to learn how the connection to an MNM Database is managed, 
# this is the file-to-be.


mnmdbConnection <- S7::new_class(
  name = "mnmdbConnection",
  properties = list(
    auth = S7::new_property(S7::class_any, default = NULL),
    database_connection = S7::new_property(S7::class_any, default = NULL)
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



connect <- S7::new_generic("connect", "conn")
S7::method(connect, mnmdbConnection) <- function(conn) {

  auth <- conn@auth # shortcut

  # for orientation
  db_label <- sprintf("%s@%s/%s", auth@user, auth@host, auth@database)


  # connect to database
  #
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
    message(glue::glue('error in connecting {db_label}:'))
    message(wrnmsg)
  })

  # register disconnect for finalization
  # https://stackoverflow.com/a/41179916
  reg.finalizer(
    .GlobalEnv,
    function(e){
      DBI::dbDisconnect(database_connection)
      message(sprintf("MNE database connection %s gracefully disconnected.", db_label))
    },
    onexit = TRUE
  )

  conn@database_connection <- database_connection

  return(invisible(conn))

}
