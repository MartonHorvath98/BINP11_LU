# mtDNA Heritage Explore
## Directory tree
```bash
.
├── ShinyApp
├── bin
├── config
└── data
    ├── AmtDB
    ├── ref
    └── test
```
## Set up the environment
Download and install mamba through the recommended miniforge [installation](https://github.com/conda-forge/miniforge) process.
```bash
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh
```
Then, use mamba to set up the environment, using a yaml configuration guide, to run the scripts.
```bash
mamba create --name mtDNA --no-default-packages
mamba env update -n mtDNA --file config/environment.yml
mamba activate mtDNA

# packages in environment at /root/miniforge3/envs/malaria:
#
# Name                    Version                   Build  
bioawk                    1.0                 he4a0461_10    bioconda
emboss                    6.6.0                hdde3b0b_8    bioconda
entrez-direct             13.9            pl5262he881be0_2    bioconda
fasttree                  2.1.10               h779adbc_6    bioconda
mafft                     7.520                h031d066_3    bioconda
```
## Sample preprocessing
The files originating from [AmtDB](https://amtdb.org/) have been severly corrupted, hence several steps were needed to be completed before using them in the Shiny application. These steps included:
1. Deselecting samples that did not have a whole mtDNA genome sequence. 
2. Removing linebreaks that occured within the fasta file at random locations.
3. Running Multiple Sequence alignment on the 887 sequences.
4. Calculating position-specific information content for each base.
5. Variant calling.

```bash
# Remove line breaks from the FASTA file
    echo -e "Converting FASTA file to one-line format...\n"
    awk '/^>/ {if (NR>1) print ""; print $0; next} {printf "%s", $0} END {print ""}' "$in_file" > "${in_file%.fasta}_oneline.fasta"

    # Filter the input file based on the filter file
    echo "Filtering input file based on the filter file..."
    if [ -f "$filter" ]; then
        echo "Filtering input file based on the filter file..."
        grep -A 1 -wFf "$filter" --no-group-separator "${in_file%.fasta}_oneline.fasta" > "${in_file%.fasta}_filtered.fasta"
    fi

    # Run multiple sequence alignment using mafft
    echo -e "Running multiple sequence alignment...\n"
    mafft --auto --thread "$threads" "${in_file%.fasta}_filtered.fasta" > "${in_file%.fasta}_msa.fasta"
    # download the rCRS reference sequence from NCBI
    reference="data/reference/"
    mkdir -p $reference
    esearch -db nuccore -query "NC_012920.1" | efetch -format fasta > "$reference/rCRS.fasta"
    # Re-run the MSA with the rCRS reference sequence
    mafft --add "$reference/rCRS.fasta" "${in_file%.fasta}_msa.fasta" > "${in_file%.fasta}_msa.fasta"

    # Use bioawk to calculate base information content
    echo -e "Calculating information content from MSA...\n"

    # Transpose the MSA to calculate information content
    awk '/^>/ { if (NR>1) print ""; print $0; next} { printf "%s", $0 } END {print ""}' "${in_file%.fasta}_msa_ref.fasta" |\
        grep -v "^>" |\
        awk 'BEGIN { FS = "" } { 
            for (i = 1; i <= NF; i++) {
                a[NR, i] = $i 
            } 
        } 
        NF > p { 
            p = NF 
        } 
        END { 
            for (j = 1; j <= p; j++) { 
                str = a[1, j]; 
                for (i = 2; i <= NR; i++) { 
                    str = str a[i, j] 
                } 
                print str 
            } 
        }' > "${in_file%.fasta}_transposed.txt"

    awk 'BEGIN { FS = ""; OFS="\t"; OFMT = "%.4f"; print "Pos", "Info" } {

        delete charCounts
        rowLength = length($0)
        sum = 0

        # Count occurrences of each character
        for (i = 1; i <= rowLength; i++) {
            charCounts[$i]++
        }

        # Calculate and sum up p * log(p) for each character, where log is natural log
        for (char in charCounts) {
            p = charCounts[char] / rowLength
            if (p > 0) {
                sum -= p * log(p)
            }
        }
        
        print NR, 2 - sum
    }' "${in_file%.fasta}_transposed.txt" > "${in_file%.fasta}_info_content.txt"

    echo "Multiple sequence alignment and information content calculation completed successfully!"

    # Remove intermediate files
    rm "${in_file%.fasta}_oneline.fasta" "${in_file%.fasta}_filtered.fasta" "${in_file%.fasta}_transposed.txt"

    # Find variants in the MSA
    echo -e "Finding variants in the MSA...\n"
    snp-sites -v "${in_file%.fasta}_msa_ref.fasta" > "${in_file%.fasta}_variants.vcf"  
```

## R Shiny Webapp

### 1. Human whole mitochondrial genome phylogenetic tree
Working with the list of istinct mutations from the mtDNA tree build 17 (18-Feb-2016) [(phylotre.org)](https://www.phylotree.org/tree/index.htm), and the hierarchical structure between haplogroups, I recreated the phylogenetic tree structure. 

```bash
mutation        pos     derAl   hapGrp  ancAl
T10C    10      C       J1b1a1c T
A16t    16      t       G3a1    A
A16t    16      t       K1a11   A
C26T    26      T       R0a1b   C
```

```bash
A1      A_T152C_T16362C
A1a1    A1a
A1a     A1
A2      A_T152C_T16362C
A2_C64T A2
```
The R code to execute this: 1) roots the tree with the mitochondrial Eve ("mt-MRCA"), then recursively builds children node, finding direct links between nodes in the niput file, 2) when appending a node, adds the available meta information to the attributes, 3) finally, a second function converts the tree to a newik format for pruning, and plotting via `ggtree()`.
```R
# Function to build a phylogenetic tree
buildTree <- function(df, meta, mut) {
  # Create a root node
  root <- Node$new("mt-MRCA")
  
  # Recursive function to add children
  addChildren <- function(node) {
    children <- df[df$from == node$name, "to"]
    for (child in children) {
        # Add child node with additional information
        childNode <- node$AddChild(
            child, 
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
        return(
            paste0("(", paste(childStrings, collapse = ","), ")",stringr::str_replace_all(node$name, "'","_"))
        )
  }
}
```

Pruning of the tree is executed via a self-defined recursive function, that trims the tree until predefined set of nodes become the only leaves. This set of node is the same as in the case the phylotree database: *`"L0", "L1", "L2", "L3", "L4", "L6", "Q", "M", "M7", "C", "Z", "E", "G", "D", "N", "O", "I", "W", "Y", "A", "X", "R", "P", "HV", "H", "V", "J", "T", "F", "B", "K"`*.
```R
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
```