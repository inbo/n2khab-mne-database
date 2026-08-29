

auth <- mnmdbAuth(
  folder = "dbstructure_test",
  host = "127.0.0.1",
  port = "5432",
  database = "sandbox",
  user = "guest"
)

describe(auth)


authcfg <- mnmdbAuth(
  config_file = file.path("config_files", "test.conf")
)

describe(authcfg)
