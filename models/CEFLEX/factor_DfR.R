function(tablefile, design) {
  factor <- 100

  reds <- count_red_elements("CEFLEX", tablefile, design)
  yellows <- count_yellow_elements("CEFLEX", tablefile, design)

  if (is.na(reds) | is.na(yellows)) {
    return(NA)
  }


  # special logic if the DfR table is a CEFLEX D4ACE DfR table
  # these tables contain a minimum amount of PE or PP in the 'Materials' row; as this modelling tool does not allow for
  # target material content requirements in the Excel DfR table inputs, it needs to be considered specifically here
  if (grepl("CEFLEX", tablefile)) {
    dom <- dominantmaterial_percent(design)

    if (dom < 80) {
      reds <- reds + 1
      logger(sprintf("> Target material content of %s %% led to an additional red element being considered.\n", dom))
    }

    if (dom >= 80 & dom < 90) {
      yellows <- yellows + 1
      logger(sprintf("> Target material content of %s %% led to an additional yellow element being considered.\n", dom))
    }
  }

  if (reds > 0) {
    logger(sprintf("Rule 1: Applying, setting score to zero if one or more reds (%s)\n", paste(list_red_elements("RAMTF", tablefile, design), collapse = ", ")))
    logger(sprintf("Rule 3: Not applying as rule 1 was already applied\n"))
    return(0)
  } else {
    logger(sprintf("Rule 1: Not applying as no red listed elements\n"))
  }



  if (yellows == 0) {
    logger(sprintf("Rule 3: Not applying as no yellow elements found\n"))
  }

  if (yellows == 1) {
    logger(sprintf("Rule 3: Applying, setting score to a maximum of 94%% if one yellow (%s)\n", paste(list_yellow_elements("RAMTF", tablefile, design), collapse = ", ")))
    factor <- 94
  }

  if (yellows == 2) {
    logger(sprintf("Rule 3: Applying, setting score to a maximum of 90%% if two yellows (%s)\n", paste(list_yellow_elements("RAMTF", tablefile, design), collapse = ", ")))
    factor <- 90
  }

  if (yellows == 3) {
    logger(sprintf("Rule 3: Applying, setting score to a maximum of 85%% if three yellows (%s)\n", paste(list_yellow_elements("RAMTF", tablefile, design), collapse = ", ")))
    factor <- 85
  }

  if (yellows > 3) {
    logger(sprintf("Rule 3: Applying, setting score to a maximum of 80%% if four or more yellows (%s)\n", paste(list_yellow_elements("RAMTF", tablefile, design), collapse = ", ")))
    factor <- 80
  }

  factor
}
