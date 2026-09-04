#!usr/bin/env Rscript

# remotes::install_github("inbo/mnmdb", ref = "oopdb")


library("mnmdb")

auth <- mnmdb::mnmdbAuthConf(
    config_file = file.path("config_files", "mnmgwdb.conf"),
    connect_passwordless = TRUE
  )
describe(auth)
print(auth@connect_passwordless)

## debugging
# database_connection <- DBI::dbConnect(
#     RPostgres::Postgres(),
#     dbname = auth@database,
#     host   = auth@host,
#     port   = auth@port,
#     user   = auth@user
#   )

mnmdbconn <- mnmdb::mnmdbConnection(
    auth = mnmdb::mnmdbAuthConf(
      config_file = file.path("config_files", "mnmgwdb.conf"),
      connect_passwordless = TRUE
    )
  )
mnmdb::describe(mnmdbconn)

mnmdbconn <- mnmdbconn |> mnmdb::connect()
mnmdb::describe(mnmdbconn)
