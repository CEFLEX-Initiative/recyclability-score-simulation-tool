function(tablefile, design) {
    reds <- count_red_elements("CEFLEX", tablefile, design)
    if (!is.na(reds) & reds == 0) {
      if (count_removed_elements("CEFLEX", tablefile, design)) {
        logger(sprintf("Rule 2: Applying, removing weight of removed components from score (%s)\n", list_removed_elements("RAMTF", design, componentsonly = T)))
      } else {
        logger(sprintf("Rule 2: Not applying, no removed integrated components\n"))
      }
    } else {
      logger(sprintf("Rule 2: Not applying as rule 1 was already applied\n"))
    }

    factor <- (100 - weight_removed_elements(design, componentsonly = T))
  }