source("ShinyApp/helpers.R")

# Load the ancient metadata
metadata <- read.csv("data/mtDNA_meta/mtdb_metadata.txt", sep = "\t", header = TRUE)

# Load the consensus mtDNA sequence fasta file
fasta <- read.fasta("data/mtDNA_meta/mtdb_consensus.fasta")

# Load information content list
info_content <- read.csv("data/mtDNA_meta/msa_info_content.txt", sep = "\t",
                         header = TRUE)
info_content <- info_content %>% 
  # create a ggplot with columns, where Pos is on the x-axis and Info is on the y-axis,
  # and the color of the line is determined by Info, color scheme viridis
  ggplot(aes(x = Pos, y = Info, color = Info)) +
  geom_col() +
  scale_color_viridis() +
  theme_minimal()
  