for (src in unique(assessment_outcomes$Source)) {
  outgrid <- filter(assessment_outcomes, Source == src)
  outgrid <- mutate(outgrid, `Scoring system` = fct_inorder(`Scoring system`))
  outgrid <- mutate(outgrid, `DfR table` = fct_inorder(`DfR table`))

  for (scoringsystem in unique(outgrid$`Scoring system`)) {
    outgrid2 <- filter(outgrid, `Scoring system` == scoringsystem)

    outgrid2 <- mutate(outgrid2, `Grade` = factor(`Grade`, levels = c("A", "B", "C", "Not recyclable", "Cannot assess")))

    p <- ggplot(outgrid2, aes(x = `Scoring system`, y = `Packaging name`, fill = `Grade`)) +
      geom_tile(show.legend = TRUE) +
      geom_text(aes(label = ifelse(`Needs testing`, paste("Needs test (", Stream, ",", `# tests`, " element(s))", sep = ""), paste(round(Score, 1), "% (", Stream, ",Y:", `# yellow`, ",R:", `# red`, ")", sep = ""))), size = 2, colour = "white") +
      geom_text(aes(label = ifelse(is.na(Stream), "No stream", "")), size = 2, colour = "white") +
      scale_fill_manual(values = ppwr_pal, na.translate = TRUE) +
      facet_grid(cols = vars(outgrid2$`DfR table`), rows = vars(outgrid2$Group), scales = "free_y", space = "free") +
      theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        strip.text.x = element_text(size = 5)
      )

    ggsave(paste("output/Graphical results for design input file ", toupper(src), " (scoring system ", toupper(scoringsystem), ").png", sep = ""), p, width = 13, height = 5.5)
  }
}
