#!usr/bin/env Rscript

test_auth <- mnmdbAuth(
  host = "127.0.0.1",
  port = "5432",
  user = "guest",
  password = "abc123",
  database = "sandbox"
)


mnmdb_connection <- mnmdbConnection(
  auth <- test_auth
)
mnmdb_connection <- mnmdb_connection |> connect()


DBI::dbWriteTable(
  conn = mnmdb_connection@database_connection,
  name = DBI::Id("test", "mtcars"),
  value = mtcars,
  overwrite = TRUE
)
# DBI::dbListTables(mnmdb_connection@database_connection)

test_cars <- dplyr::tbl(mnmdb_connection@database_connection, DBI::Id("test", "mtcars"))
test_cars |> knitr::kable()
