################################################################################
# Load required packages                                                       #
################################################################################
# Utility packages
if (!require("dplyr")) install.packages("dplyr")
library(dplyr)
if (!require("stringr")) install.packages("stringr")
library(stringr)
if (!require("Biostrings")) install.packages("Biostrings")
library(Biostrings)
if (!require("seqinr")) install.packages("seqinr", repos="http://R-Forge.R-project.org")
library(seqinr)
if (!require("data.tree")) install.packages("data.tree")
library(data.tree)
if (!require("ape")) install.packages("ape")
library(ape)
if (!require("treeio")) install.packages("treeio")
library(treeio)
# Visualization packages
if (!require("ggplot2")) install.packages("ggplot2")
library(ggplot2)
if (!require("ggtree")) install.packages("ggtree")
library(ggtree)
if (!require("ggrepel")) install.packages("ggrepel")
library(ggrepel)
# Shiny packages
if (!require("shiny")) install.packages("shiny")
library(shiny)
if (!require("shinyjs")) install.packages("shinyjs")
library(shinyjs)
if (!require("shinyBS")) install.packages("shinyBS")
library(shinyBS)
if (!require("shinyFiles")) install.packages("shinyFiles")
library(shinyFiles)
if (!require("shinyWidgets")) install.packages("shinyWidgets")
library(shinyWidgets)
if (!require("shinybusy")) install.packages("shinybusy")
library(shinybusy)
if (!require("shinyalert")) install.packages("shinyalert")
library(shinybusy)
if (!require("DT")) install.packages("DT")
library(DT)
if (!require("fontawesome")) install.packages("fontawesome")
library(fontawesome)

################################################################################
# Helper functions                                                             #
################################################################################

################################################################################
# 1. ) Handle user input files                                                #
################################################################################

# Function to read user input file
user_input <- function(file){
  input <- NULL
  delim <- ifelse(grepl(",", readLines(file, n = 1)), ",", "\t")
  # Check if the input file is a txt or tsv file
  tryCatch({ input <- read.table(file, header = TRUE, sep = delim)},
           error = function(e) {
             stop("Input is not a txt or tsv file: ", e$message)
           })
  # Check if the input file has the correct number of columns
  if (ncol(input) < 4) {
    stop("Input file must have four columns: rsid, chromosome, position,
         and allele(s)")
  } else {
    # Rearrange columns if reference column is missing
    input <- input %>% 
             dplyr::select(c(1,2,3,4))
    # Set column names
    colnames(input) <- c("rsid","chromosome", "position", "alternative")
    # Pre-processing the input file
    input <- input %>% 
      # Convert columns to appropriate data types
      dplyr::mutate(rsid = as.character(rsid),
                    chromosome = as.character(chromosome),
                    position = as.numeric(position),
                    alternative = as.character(alternative)) %>%
      # Change missing alleles to "-"
      dplyr::mutate(alternative = ifelse(alternative %in% c("","--") | is.na(alternative), "-", alternative)) %>%
      # Select rows with valid chromosomes
      dplyr::filter(grepl("rs", rsid) & chromosome %in% c("MT", "chrM", "26"))
  }
  # Check if the input file has valid variants
  if (nrow(input) == 0) {
    stop("No valid variants found in the input file")
  } else {
    return(input)
  }
}

compareStrings <- function(str1, str2) {
  # Split the strings into vectors
  vec1 <- unlist(strsplit(str1, ","))
  vec2 <- unlist(strsplit(str2, ","))
  
  # Find matches and extras
  matches <- intersect(vec1, vec2)
  extra_str1 <- setdiff(vec1, vec2)
  extra_str2 <- setdiff(vec2, vec1)
  
  # Return counts
  list(
    matches = length(matches),
    user_spec = length(extra_str1),
    haplo_spec = length(extra_str2)
  )
}

################################################################################
# 2. ) Create phylogenetic tree                                                #
################################################################################
# Function to build a phylogenetic tree
buildTree <- function(df, meta, mut) {
  # Create a root node
  root <- Node$new("mt-MRCA")
  
  # Recursive function to add children
  addChildren <- function(node) {
    children <- df[df$from == node$name, "to"]
    for (child in children) {
      # Add child node with additional information
      childNode <- node$AddChild(child, 
                                 mutations = mut[mut$hapGrp == child, "Mutations"],
                                 identifier = meta[meta$mt_hg == child, "identifier"],
                                 age = meta[meta$mt_hg == child, "age"],
                                 latitude = meta[meta$mt_hg == child, "latitude"],
                                 longitude = meta[meta$mt_hg == child, "longitude"])
      addChildren(childNode) # Recursion for any children of the current child
    }
  }
  # Start the tree building process
  addChildren(root)
  return(root)
}

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

################################################################################
# 3. ) Tree manipulations                                                      #
################################################################################
# Trim tree for plotting
trimTree <- function(node, leaves) {
  # Base case: The node is a leaf
  if (isLeaf(node)) {
    # Check if the leaf's name is not in the predefined list of leaves to keep
    if (!(node$name %in% leaves)) {
      # Remove the leaf node
      node$parent$RemoveChild(node$name)
    }
  } else {
    # Recursive case: The node has children
    # Make a copy of the list to modify it in the loop    
    childrenNames <- names(node$children)
    for (childName in childrenNames) {
      child <- node$children[[childName]]
      trimTree(child, leaves)
    }
    # After recursion, check if the node has children left
    if (length(node$children) == 0) {
      # If all children were removed and it's not the root node (assuming root has no name or a specific name)
      if (!is.null(node$name) && !(node$name %in% leaves)) {
        node$parent$RemoveChild(node$name)
      }
  }}
}

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