################################################################################
# 1.) Load analysis data                                                       #
################################################################################

# load meta information from AmtDB
AmtDB <- read.csv("./data/AmtDB/amtdb_meta.txt", sep = "\t", header = TRUE)
AmtDB <- AmtDB %>% 
  #dplyr::select(identifier, mt_hg, year_from, year_to, latitude, longitude) %>% 
  dplyr::filter(mt_hg != "" & mt_hg != "-") %>% 
  dplyr::mutate(expand = "&oplus;",
                mt_hg = as.factor(mt_hg),
                age = round((year_from + year_to) / 2, -2)) %>% 
  dplyr::select(!c(alternative_identifiers, group, comment, site, site_detail,
                ychr_hg, ychr_snps, date_detail, reference_names, reference_links,
                reference_data_links, c14_lab_code, c14_layer_tag, c14_sample_tag,
                bp, sequence_source, avg_coverage)) %>% 
  dplyr::relocate(expand, identifier, mt_hg, age, .before = everything())

meta_data <<- AmtDB


reference <- seqinr::read.fasta('./data/ref/rCRS.fasta')

# load mutational data from AmtDB
mutations <- read.table("./data/AmtDB/mutations.txt", 
                        quote = "", header = TRUE, sep = "\t",
                        stringsAsFactors = FALSE)

# load information content
info_content <- read.table("./data/ref/info_content.txt", 
                           quote = "", header = TRUE, sep = "\t",
                           stringsAsFactors = FALSE)

# load full list of mutations
mutations.full <- read.table("./data/AmtDB/mutations_full.txt", 
                              header = TRUE, sep = "\t",
                              stringsAsFactors = FALSE)

################################################################################
# 2.) Create utility datasets                                                  #
################################################################################

# extract haplogroup specific mutations
mutations.haplo <- mutations %>% 
  group_by(hapGrp) %>%
  summarise(Mutations = paste(mutation, collapse=","))

# extract position specific mutations
mutations.position <- mutations %>% 
  dplyr::select(!hapGrp) %>%
  dplyr::distinct(mutation, .keep_all = T) %>%
  setNames(c("Mutations", "position", "alternative", "reference")) %>% 
  dplyr::mutate(alternative = ifelse(alternative == "", "-", alternative),
                reference = ifelse(reference == "", "-", reference)) %>% 
  dplyr::left_join(., info_content, by = c("position" = "Pos"))

################################################################################
# 3.) Create phylogenetic tree                                                 #
################################################################################
# load phylogeny data
tree_data <- read.table("data/AmtDB/hierarchy.txt", 
                        quote = "", header = F, sep = "\t",
                        col.names = c("to", "from"))
tree_data <- tree_data[,c(2,1)]
# create tree
tree <- buildTree(tree_data, AmtDB, mutations.haplo)

# prune tree
tree_clone <- Clone(tree)
tips <- c("L0","L1","L2","L3","L4","L6","Q","M","M7","C","Z","E","G","D","N",
          "O","I","W","Y","A","X","R","P","HV","H","V","J","T","F","B","K")
trimTree(tree_clone, tips)

# convert tree to newick format
newickString <- paste0(convertToNewick(tree_clone), ";")
newickString <- gsub("()", "", newickString, fixed = TRUE)

haplot_tree <<- ape::read.tree(text = newickString)




################################################################################
# 4.) Update list of mutations based on phylogeny                              #
################################################################################
# update mutations based on tree

# Function to read user input file upon clicking the 'goButton'
# output$dataTable <- DT::renderDataTable({
#   req(input$goButton)
#   path <- filePath()
#   req(path)
#   tryCatch({
#     data <- user_input(path)
#     datatable(
#       data,
#       options = list(
#         pagelength = 10
#       ),
#       rownames = FALSE,
#       escape = FALSE,
#       callback = DT::JS(
#        "table.on('click', 'tr', function () {",
#        "  var tr = $(this).closest('tr');",
#        "  var row = table.row(tr);",
#        "  var header = table.columns().header();",
#        "  var headerData = [$(header[2]).text(), $(header[3]).text()];",
#        "  if (row.child.isShown()) {",
#        "    row.child.hide();",
#        "    tr.removeClass('shown');",
#        "  } else {",
#        "    var rowData = row.data();",
#        "    row.child('<strong>' + headerData[0] + '</strong>' + '\\t' + rowData[2] + '\\n' + ",
#        "              '<strong>' + headerData[1] + '</strong>' + '\\t' + rowData[3]",
#        "              ).show();", 
#        "    tr.addClass('shown');",
#        "  }",
#        "});")
#       )
#        
#       return(dt))
#   }, error = function(e) {
#     output$errorMsg <- renderText({ e$message })
#     NULL
#   })
# }, server = FALSE) # Set server = FALSE for large datasets









# full.haplo <- lapply(mutations.haplo$hapGrp, function(x){
#   nodes <- FindNode(tree, x)$path
#   nodes <- nodes[!nodes %in% c("mt-MRCA")]
#   
#   mutations <- NULL
#   for (node in nodes){
#     mutations <- c(mutations, unlist(str_split(mutations.haplo$Mutations[mutations.haplo$hapGrp == node],",")))
#   }
#   return(mutations)
# })
# 
# names(full.haplo) <- mutations.haplo$hapGrp
# 
# mutations.full <- data.frame(hapGrp = names(full.haplo), 
#                              Mutations = sapply(full.haplo, function(x) paste(unique(x), collapse = ","))) 
# 
# 
# write.table(mutations.full, "data/AmtDB/mutations_full.txt", 
#             sep = "\t", na = "NA", dec = ".", row.names = F, col.names = T)