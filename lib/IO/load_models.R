# Load all models

# initialise an empty list of scoring systems
scoringsystems <- tribble(~ID, ~Name, ~Description, ~Title, ~usesdfr, ~factor_weight, ~factor_DfR, ~calculate_score, ~factor_other, ~mod_grade, ~Series)

# load files from the models subdirectory
fils <- list.files("models", pattern = "*.R", full.names = FALSE)

for (fil in fils) {
  # load the actual R code for the model into a variable using the 'source' function
  thismodel <- source(paste("models", fil, sep = "/"))$value

  # create functions not provided by the model as empty stubs, returning NA
  if (is.null(thismodel$factor_weight)) {
    thismodel$factor_weight <- list(function(sys, tablefile, design) {
      return(NA)
    })
  }
  if (is.null(thismodel$factor_DfR)) {
    thismodel$factor_DfR <- list(function(sys, tablefile, design) {
      return(NA)
    })
  }
  if (is.null(thismodel$factor_other)) {
    thismodel$factor_other <- list(function(sys, tablefile, design) {
      return(NA)
    })
  }

  # create a stub for the function to modify the grade independent of the score, in case the model does not provide such a function
  if (is.null(thismodel$mod_grade)) {
    thismodel$mod_grade <- list(function(grad, sys, tablefile, design) {
      return(grad)
    })
  }

  scoringsystems <- add_row(scoringsystems, thismodel, ID = paste(fil, sep = "-"))
}
