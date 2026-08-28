#!usr/bin/env Rscript

# this file contains the mnmdb authentication object.

mnmdbAuth <- S7::new_class(
  name = "mnmdbAuth",
  properties = list(
    config_file = S7::class_character
  ),
  validator = function(self) {
    if (isFALSE(file.exists(self@config_path))) {
      return("The config file @config_file does not exist!")
    }
  }
)
