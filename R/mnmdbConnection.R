#!usr/bin/env Rscript

# If you want to learn how the connection to an MNM Database is managed, 
# this is the file-to-be.


mnmdbConnection <- S7::new_class(
  name = "mnmdbConnection",
  properties = list(
    auth = S7::new_property(S7::class_any, default = NULL)
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
