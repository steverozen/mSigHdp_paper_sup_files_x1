# Please run this script from the top directory
if (basename(getwd()) != "Liu_et_al_Sup_Files") {
  stop("Please run from top level directory, Liu_et_al_Sup_Files")
}

##################################################################
##      Install dependency packages and create directories      ##
##################################################################
if (!requireNamespace("ICAMS", quietly = TRUE)) {
  remotes::install_github("steverozen/ICAMS", ref = "v3.0.5-branch")
}
library(ICAMS)
source("./common_code/data_gen_utils.R")

id_plot_home <- "./indel/input/"
dataset_names <- c("Noiseless", "Realistic", "Moderate")
file_suffixes <- c("no_noise", "realistic_noise", "moderate_noise")
identifiers <- gsub(pattern = "_", replacement = " ", x = file_suffixes)

#################################################################
##               Plot indel synthetic tumor spectra               ##
#################################################################
for (i in seq_along(dataset_names)) {
  input_file <-
    file.path(id_plot_home, dataset_names[i], "ground.truth.syn.catalog.csv")
  catalog <- ICAMS::ReadCatalog(input_file)

  output_file <-
    file.path(
      id_plot_home, dataset_names[i],
      paste0("indel_syn_tumor_spectra_", file_suffixes[i], ".pdf")
    )
  plot_catalog_to_pdf(
    catalog = catalog,
    identifier = identifiers[i],
    file = output_file
  )
}