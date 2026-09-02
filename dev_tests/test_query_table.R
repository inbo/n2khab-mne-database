#!usr/bin/env Rscript


mnmdbconn <- mnmdb::mnmdbConnection(
    auth = mnmdb::mnmdbAuth(user = "guest", database = "sandbox")
  ) |>
  mnmdb::connect()

DBI::dbWriteTable(
  conn = mnmdbconn@database_connection,
  name = DBI::Id("test", "mtcars"),
  value = mtcars,
  overwrite = TRUE
)

mnmdbconn |> query_table(
    DBI::Id("test", "mtcars"),
    subselect = c("mpg", "cyl", "disp", "hp")
  )  %>%
  head(5) %>%
  knitr::kable()
