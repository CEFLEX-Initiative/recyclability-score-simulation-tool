tibble_row(
  Name = "CEFLEX", Title = "CEFLEX proposal", Description = "CEFLEX proposal for a PPWR scoring system", 
  usesdfr = TRUE,
  factor_weight = source("models/CEFLEX/factor_weight.R")$value,
  factor_DfR = source("models/CEFLEX/factor_DfR.R")$value,
  calculate_score = source ("models/CEFLEX/calculate_score.R")$value
)
