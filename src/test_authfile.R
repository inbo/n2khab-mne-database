

auth <- mnmdbAuth(
  folder = "dbstructure_test",
  host = "127.0.0.1",
  port = "5432",
  database = "sandbox",
  user = "guest"
)

describe(auth)


authcfg <- mnmdbAuthConf(
  config_file = file.path("config_files", "test.conf")
)

describe(authcfg)
S7::S7_class(authcfg)

mnmdbConnection(auth = authcfg)
