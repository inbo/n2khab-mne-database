#!usr/bin/env Rscript

auth <- mnmdbAuth(
  folder = "dbstructure_test",
  # host = "127.0.0.1",
  # port = "5432",
  database = "sandbox",
  user = "guest",
  # password = "abc123"
)

describe(auth)
print(auth@password)


authcfg <- mnmdbAuthConf(
  config_file = file.path("config_files", "test.conf")
)

describe(authcfg)
S7::S7_class(authcfg)
print(authcfg@password)

mnmdbConnection(auth = authcfg)



# TODO test integer port
