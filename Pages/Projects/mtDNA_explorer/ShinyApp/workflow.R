# load meat informations
metadata <- read.csv("data/mtDNA/mtdb_metadata.txt", sep = "\t", header = TRUE)
metadata <- metadata %>% 
  select(identifier, mt_hg, year_from, year_to, latitude, longitude) %>% 
  filter(mt_hg != "" & mt_hg != "-") %>% 
  mutate(mt_hg = as.factor(mt_hg),
         age = round((year_from + year_to) / 2, -2)) %>% 
  select(-year_from, -year_to)


# load mutational data
mutations <- read.table("data/mtDNA/mt_phyloTree_b17_Mutation.txt", 
                        quote = "", header = TRUE, sep = "\t",
                        stringsAsFactors = FALSE)
mutation.df <- mutations %>% 
  group_by(hapGrp) %>%
  summarise(Mutations = paste(mutation, collapse=","))

# load phylogeny data
tree_data <- read.table("data/mtDNA/mt_phyloTree_b17_Tree2.txt", 
                        quote = "", header = F, sep = "\t",
                        col.names = c("to", "from"))
tree_data <- tree_data[,c(2,1)]

buildTree <- function(df) {
  # Create a root node
  root <- Node$new("mt-MRCA")
  
  # Recursive function to add children
  addChildren <- function(node) {
    children <- df[df$from == node$name, "to"]
    for (child in children) {
      childNode <- node$AddChild(child, 
                                 mutations = mutation.df[mutation.df$hapGrp == child, "Mutations"],
                                 identifier = metadata[metadata$mt_hg == child, "identifier"],
                                 age = metadata[metadata$mt_hg == child, "age"],
                                 latitude = metadata[metadata$mt_hg == child, "latitude"],
                                 longitude = metadata[metadata$mt_hg == child, "longitude"])
      addChildren(childNode) # Recursion for any children of the current child
    }
  }
  
  # Start the tree building process
  addChildren(root)
  
  return(root)
}

tree <- buildTree(tree_data)

passChildAttributeToParent <- function(node, value) {
  # Base case: If the node is a leaf, return its own value
  if(node$isLeaf) {
    return(node$value)
  } else {
    # Recursive case: Traverse the children
    childValues <- sapply(node$children, passChildAttributeToParent)
    # Update the parent node with the sum of child values
    node$value <- paste0(childValues)
    return(node$value)
  }
}

removeMissing <- function(node, attribute) {
  print(paste("Attribute is: ", attribute))
  # Base case: The node is a leaf
  if (isLeaf(node)) {
    # Check if the identifier is character(0)
    if (length(node[[attribute]]) == 0) {
      # Remove the leaf node
      print(paste("Removing:", node$name))
      node$parent$RemoveChild(node$name)
    } else {
      # Copy identifier to the parent node, appending it to existing identifiers if any
      if (length(node$parent[[attribute]]) == 0) {
        print(paste("Copying", node$name, "to", node$parent$name))
        node$parent[[attribute]] <- node[[attribute]]
      } else {
        # Assuming identifier is a character vector, concatenate them
        print(paste("Adding", node$name, "to", node$parent$name))
        node$parent[[attribute]] <- c(node$parent[[attribute]], node[[attribute]])
      }
    }
  } else {
    # Recursive case: The node has children
    for (child in node$children) {
      print(paste("Visiting", child$name))
      removeMissing(child, attribute)
    }
    # After recursion, if the node has become a leaf, check the identifier again
    # This might happen if all children were removed
    if (isLeaf(node) && length(node[[attribute]]) == 0) {
      print(paste("Removing:", node$name))
      node$parent$RemoveChild(node$name)
    }
  }
}

collectUniqueIdentifiers <- function(node, identifiers = character()) {
  # If the node has an identifier, add it to the list
  if (!is.null(node$identifier)) {
    identifiers <- c(identifiers, node$identifier)
  }
  
  # If the node has children, recurse into each child
  if (!is.leaf(node)) {
    for (child in node$children) {
      identifiers <- collectUniqueIdentifiers(child, identifiers)
    }
  }
  
  # Return the identifiers collected so far
  return(identifiers)
}

treeClone <- Clone(tree)
removeMissing(treeClone, "identifier")

plot(treeClone)

# Function to convert data.tree to Newick format
convertToNewick <- function(node) {
  if (is.leaf(node)) {
    return(node$name)
  } else {
    childStrings <- sapply(node$children, convertToNewick)
    return(paste0("(", paste(childStrings, collapse = ","), ")", 
                  stringr::str_replace_all(node$name, "'","_")))
  }
}

# Example usage:
newickString <- paste0(convertToNewick(treeClone), ";")
newickString <- gsub("()", "", newickString, fixed = TRUE)

library(ggtree)
library(stringr)
library(ggrepel)
library(ape)
tree2plot <- ape::read.tree(text = newickString)
trimmed_tree <- drop.tip(tree2plot, tree2plot$tip.label[(20+1):length(tree2plot$tip.label)])


(p <- ggtree(trimmed_tree) + 
    geom_tiplab() + 
    geom_nodelab() +
    geom_cladelabel(node=26, label="Haplogroup N", 
                    color="red4", offset=.4, align=TRUE) + 
    geom_cladelabel(node=23, label="Haplogroup M", 
                    color="brown1", offset=.4, align=TRUE) + 
    geom_cladelabel(node=22, label="Haplogroup L3", 
                    color="blue", offset=1.2, align=TRUE) + 
    theme_tree2())

str_replace_all(label, "_", "`")

# Load multiple sequence alignment
msa <- readDNAMultipleAlignment("data/mtDNA/mtdb_sequences_msa_ref.fasta", format = "fasta")
.filter <- metadata %>% 
  dplyr::filter(mt_hg %in% trimmed_tree$tip.label) %>% 
  dplyr::group_by(mt_hg) %>%
  dplyr::slice(1) %>% 
  dplyr::pull(identifier)

msa <- msa@unmasked[which(names(msa@unmasked) %in% .filter),]
msa <- msa[match(pruned_tree$tip.label, names(msa)),]
names(msa) <- as.character(metadata[metadata$identifier %in% names(msa), "mt_hg"])
writeXStringSet(msa, "data/mtDNA/mtdb_user_filtered.fasta")

pruned_tree <- drop.tip(trimmed_tree, trimmed_tree$tip.label[!(trimmed_tree$tip.label %in% names(msa))])


(m <- msaplot(ggtree(pruned_tree) + 
          geom_tiplab() + 
          geom_nodelab() +
          theme_tree2(),
        fasta = "data/mtDNA/mtdb_user_filtered.fasta",
        offset = 1.5,
        window = c(150,250)) + 
  theme(legend.position = "none"))
