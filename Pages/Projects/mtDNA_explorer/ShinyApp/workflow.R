source("ShinyApp/helpers.R")

msa_file <- "data/mtDNA_meta/mtdb_sequences_msa.fasta"

calculate_base_information_content <- function(msa_file) {
  # Read the MSA file
  alignment <- readAAStringSet(msa_file)
  
  # Calculate base information content
  base_info_content <- sapply(1:width(alignment), function(i) {
    column <- alignment[, i]
    counts <- table(column)
    entropy <- -sum((counts / sum(counts)) * log2(counts / sum(counts)))
    return(2 - entropy)  # Shannon's entropy normalized by log2(4)
  })
  
  return(base_info_content)
}

base_info_content <- calculate_base_information_content(msa_file)
