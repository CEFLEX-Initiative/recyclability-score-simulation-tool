function(sys, tablefile, design) {
    score <- 100

    fw <- factor_weight(sys, tablefile, design)
    fdfr <- factor_DfR(sys, tablefile, design)

    # if one of the factors cannot be determined, no score can be determined
    if (is.na(fw) | is.na(fdfr)) {
      return(NA)
    }

      score <- fw 

      if (fdfr < score) {
        score <- fdfr 
      }

    score
  }