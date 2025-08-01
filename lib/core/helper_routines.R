# This file contains 'helper' routines, which mainly serve to call the different parts (functions) of each model
# while performing some logical checks

factor_weight <- function(sys, tablefile, design) {
  # run the 'factor_weight' function of the model
  pull(scoringsystems[scoringsystems$ID == sys, "factor_weight"])[[1]](tablefile, design)
}

factor_other <- function(sys, tablefile, design) {
  # run the 'factor_other' function of the model
  pull(scoringsystems[scoringsystems$ID == sys, "factor_other"])[[1]](tablefile, design)
}

factor_DfR <- function(sys, tablefile, design) {
  # the model wants to use DfR for the score but no DfR is table available for the design --> cannot assess
  if (model_uses_DfR(sys, tablefile, design) & !DfR_table_available(tablefile, design)) {
    return(NA)
  }

  # wants to use DfR for the score butnot all elements found in DfR table --> cannot assess
  if (needstest(sys, tablefile, design)) {
    return(NA)
  }

  # run the 'factor_DfR' function of the model
  factor_DfR_per_model(sys, tablefile, design)
}

# run the 'mod_grade' function of the model
mod_grade <- function(grad, sys, tablefile, design) {
  pull(scoringsystems[scoringsystems$ID == sys, "mod_grade"])[[1]](grad, tablefile, design)
}

# run the 'calculate_score' function of the model
calculate_score_per_model <- function(sys, tablefile, design) {
  pull(scoringsystems[scoringsystems$ID == sys, "calculate_score"])[[1]](sys,tablefile, design)
}

# run the 'factor_DfR' function of the model
factor_DfR_per_model <- function(sys,tablefile, design) {
  pull(scoringsystems[scoringsystems$ID == sys, "factor_DfR"])[[1]](tablefile, design)
}


  # run the 'calculate_score' function of the model
calculate_score <- function(sys, tablefile, design) {

  # no score can be assigned if testing is needed or if unclear whether tests are needed
  if (needstest(sys, tablefile, design)) {
    return(NA)
  }

  calculate_score_per_model(sys, tablefile, design)
}