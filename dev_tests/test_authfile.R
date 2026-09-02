#!usr/bin/env Rscript

auth <- mnmdbAuth(
  host = "127.0.0.1",
  port = 5432,
  user = "guest",
  connect_passwordless = TRUE,
  password = "abc123", # will be ignored
  database = "sandbox"
)

describe(auth)
print(auth@password) # should always be NULL
print(auth@connect_passwordless)
print(S7::prop_exists(auth, "config_file"))

authcfg <- mnmdbAuthConf(
  config_file = file.path("config_files", "test.conf")
)

describe(authcfg)
S7::S7_class(authcfg)
print(authcfg@password) # should always be NULL
print(auth@connect_passwordless)

mnmdbConnection(auth = authcfg)


# TODO test integer port
