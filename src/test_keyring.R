#!usr/bin/env Rscript

# use the `seahorse` util to double check

init_keyring("mnmdb_temp")
terminate_keyring("mnmdb_temp")

lock_keyring_delayed(keyring_label = "mnmdb_temp", delay = 5)

unlock_keyring("mnmdb_temp")



keyring::key_set_with_value(
  service = "mnmdb_credentials",
  username = "tester",
  keyring = "mnmdb_temp",
  password = getPass::getPass("Test password: ")
)


existing <- keyring::key_list(keyring = "mnmdb_temp")
# existing_user <- existing$username == "tester3"
