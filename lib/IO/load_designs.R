package_designs <- NULL

# Load all the packaging structures to evaluate
for (fil in list.files("designs", pattern = "*.xlsx", full.names = TRUE)) {
    thisfile <- read_xlsx(fil, skip=2) %>% filter_all(any_vars(!is.na(.)))
    thisfile$Source <- file_path_sans_ext(basename(fil))
    package_designs <- rbind(package_designs, thisfile)
}
