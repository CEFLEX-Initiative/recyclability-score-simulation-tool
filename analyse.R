rm(list = ls())

# adopt these to your preferences
options(width = 350)
options(readxl.show_progress = FALSE)
options(warn = -1)

dir.create("output", showWarnings = FALSE)


source("lib/general_functions.R")
source("lib/core/core_routines.R")
source("lib/core/getter_routines.R")
source("lib/core/helper_routines.R")
source("lib/core/PPWR.R")
source("lib/IO/output_routines.R")
source("lib/IO/output_table.R")

printf ("\n\n\n\n")
printf("---------------------------------------------------------------------------------\n")
printf("The CEFLEX score-modeller tool\n")
printf("---------------------------------------------------------------------------------\n\n")

source("lib/IO/load_designs.R")
printf("> Loaded packaging structures: %s\n\n", paste(unique(package_designs$ID), collapse = ", "))

source("lib/IO/load_tables.R")
printf("> Loaded design tables: %s\n\n", paste(unique(dfrtables), collapse = ", "))

source("lib/IO/load_models.R")
printf("> Loaded scoring models: %s\n\n", paste(unique(scoringsystems$Name), collapse = ", "))

printf("> Analyzing designs\n")

# TODO: This is a safeguard function to deal with certain inconsistencties in the data entry for packaging designs; ideally, all entries would be 'perfect'
package_designs <- sanitize(package_designs)


assessment_outcomes <- NULL

# Process each sample 
for (sampleid in unique(package_designs$ID)) {
  sample <- filter(package_designs, ID == sampleid)

  # Process each DfR table for each sample 
  for (dfrtable in dfrtables) {

    # Process each scoring sysytem for each DfR table and each sample 
    for (scoringsystem in scoringsystems$ID) {

      # TODO: does not yet consider separate components, which would need to be iterated over here

      # reset output text 'log file'
      modellog <- c()

      sample <- assess_design(scoringsystem, dfrtable, sample, logfile)

      score <- calculate_score(scoringsystem, dfrtable, sample)
      grade <- ppwr_grade(scoringsystem, dfrtable, sample, score)
      stream <- assigned_stream(scoringsystem, dfrtable, sample)


      # assemble all results of the assessment into a dataframe row so they can be printed to an excel file
      single_outcome <- tibble(
        Source = pull(sample[1, "Source"]),
        Group = pull(sample[1, "Group"]),
        ID = pull(sample[1, "ID"]),
        `Packaging name` = pull(sample[1, "Name"]),
        `Scoring system` = scoringsystems[scoringsystems$ID == scoringsystem, ]$Title,
        `DfR table` = dfrtable,
        Dominantmaterial = dominantmaterial(sample),
        Dominantmaterialshare = round(dominantmaterial_percent(sample), 1),
        Stream = stream,
        Score = round(score, 1),
        `Grade` = grade,
        `Needs testing` = needstest(scoringsystem, dfrtable, sample),
        `Weight factor` = round(factor_weight(scoringsystem, dfrtable, sample) , 1),
        `DfR factor` = round(factor_DfR(scoringsystem, dfrtable, sample) , 1),
        `Others factor` = round(factor_other(scoringsystem, dfrtable, samplef) , 1),
        `# yellow` = count_yellow_elements(scoringsystem, dfrtable, sample),
        `# red` = count_red_elements(scoringsystem, dfrtable, sample),
        `# tests` = count_tests_needed(scoringsystem, dfrtable, sample),
        `wt% green` = round(weight_green_elements(scoringsystem, dfrtable, sample), 1),
        `wt% yellow` = round(weight_yellow_elements(scoringsystem, dfrtable, sample), 1),
        `wt% red` = round(weight_red_elements(scoringsystem, dfrtable, sample), 1),
        Greens = paste(list_green_elements(scoringsystem, dfrtable, sample), collapse = ", "),
        Yellows = paste(list_yellow_elements(scoringsystem, dfrtable, sample), collapse = ", "),
        Reds = paste(list_red_elements(scoringsystem, dfrtable, sample), collapse = ", "),
        `Required tests` = paste(list_tests_needed(dfrtable, sample), collapse = ", "),
        `Removed constituents/components` = paste(list_removed_elements(scoringsystem, sample), collapse = ", "),
        `Removed components` = paste(list_removed_elements(scoringsystem, sample, componentsonly = T), collapse = ", ")
      )

      # write a log to a text file in the output folder
      cat(output_text(single_outcome), file = paste("output/Outcome for design ", toupper(sampleid), " (DfR table ", toupper(dfrtable), ", scoring model ", toupper(scoringsystem), ").txt", sep = ""), sep = "\n", append = FALSE)

  
      assessment_outcomes <- bind_rows(assessment_outcomes, single_outcome)
    }
  }
}
printf("> Completed analyis\n")

assessment_outcomes <- arrange(assessment_outcomes, ID)
write_xlsx(assessment_outcomes, paste("output", "Full assessment results (all combinations).xlsx", sep = "/"))
printf("> Wrote output table\n")

source("lib/IO/output_graphs.R")
printf("> Wrote ouput visuals\n")


  # Print out a human-readable form for each DfR table provided in Excel format as a way to manually verify the correct entry and consideration by the tool
  for (source in dfrtables) {
    output_table(source)     
  }
printf("> Wrote formatted DfR tables for verification of inputs\n")

printf("> Finished\n")
