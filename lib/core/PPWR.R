# A function to convert a score into a PPWR recyclability performance grade based on the table 
# in PPWR Annex II, Table 3

ppwr_grade <- function(sys, tablefile, design, score) {
    grad <- NA
    if (is.na(score)) {
        grad <- NA
    } else if (score >= 95) {
        grad <- "A"
    } else if (score >= 80) {
        grad <- "B"
    } else if (score >= 70) {
        grad <- "C"
    } else {
        grad <- "Not recyclable"
    }

    if (is.na(grad)) {
        return("Cannot assess")
    }

    # allow for a post-score modification of the grade if a matching logic is provided with the scoring method
    # this means that the grade can be different to what the score corresponds to in PPWR Annex II, Table 3
    # this is not foreseen in Annex II, Table 3 but this tool allows for such a modification nonetheless
    grad <- mod_grade(grad, sys, table, design)

    grad
}


ppwr_pal <- c(
  "A" = "#00cc00",
  "B" = "#dddd99",
  "C" = "#ff9999",
  "Not recyclable" = "#ff0000",
  "Cannot assess" = "#999999"
)
