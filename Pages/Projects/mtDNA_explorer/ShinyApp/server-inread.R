################################################################################
# 1.) Handle user input files                                                  #
################################################################################

# Get the mounted volumes on the user's computer
volumes <- getVolumes()()
volumes <- c(volumes)
# Set a default path within the application folder to the test data
default_path <- paste(substring(getwd(),3,nchar(getwd())),
                      "data","test",
                      sep = "/")

# Define the server logic required to upload the file
shinyFileChoose(input, 'file', 
                roots = volumes, 
                session = session,
                defaultRoot = 'OS (C:)',
                defaultPath = default_path,
                filetypes = c('fasta', 'txt', 'csv', 'tsv'))

# Save the file path as a reactive value
filePath <- reactiveVal(NULL)
# Observer to get the file path, when selected
observe({
  if(!is.null(input$file)){
    fileSelect <- parseFilePaths(volumes, input$file)
  }
  if (nrow(fileSelect) > 0) {
    filePath(fileSelect$datapath[1])
  }
})

# Display the information popup, when the info icon is clicked
output$fileTypeInfo <- renderUI({
  shiny::tags$script(HTML('$(function () { $("#infoIcon").tooltip({title: "Input: a tab- or comma-delimited text file containing a list of SNPs with rsid, chromosome, position, alternative allele!", 
                          placement: "bottom", container: "body", html: true}); })'))
})


observeEvent(input$goButton, {
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
  haplo_tree <<- ape::read.tree(text = newickString)
  
  make_tree <- reactive({
    plot <- ggtree(haplo_tree, layout = 'circular',
                   #open.angle = 120,
                   branch.length = 'none')
    
    return(plot + 
             geom_tiplab(nudge_x = 1) +
             geom_tippoint() +
             geom_nodelab(data = filter(plot$data, label %in% c(tips, "mt-MRCA")),
                          aes(label = label), geom = 'label', nudge_x = -1) +
             theme_tree()) 
  })
  
  output$treeDisplay <- renderPlot({
    make_tree()
  })
  
  setupComplete <<- TRUE
  output$setupNeeded <- reactive({ setupComplete })
})


# Function to read user input file upon clicking the 'goButton'
output$dataTable <- DT::renderDataTable({
  req(input$goButton)
  path <- filePath()
  req(path)
  tryCatch({
    data <- user_input(path)
    data <- data %>% 
      dplyr::mutate(
        reference = toupper(reference[[1]][position])
      ) %>% 
      dplyr::filter(alternative != reference) %>% 
      dplyr::left_join(., mutations[,-4], 
                        join_by("position"=="pos","alternative"=="derAl",
                                "reference"=="ancAl")) %>% 
      dplyr::distinct() %>% 
      dplyr::select(!c("chromosome"))
    
    
    datatable(
      data,
      options = list(
        pagelength = 10,
        style = 'bootstrap',
        selection = 'none'
      ),
      rownames = FALSE) %>% 
      formatStyle(
        columns = 'mutation',
        target = 'row', # Apply the styling to the row
        backgroundColor = styleEqual(c(NA), c('lightgrey')), # Background color for missing values
        fontWeight = styleEqual(c(NA), c('normal'), c('bold')), # Bold for non-missing values
        color = styleEqual(c(NA), c('grey25'), c('black')) # Text color
      )
  }, error = function(e) {
    output$errorMsg <- renderText({ e$message })
    NULL
  })
}, server = FALSE) # Set server = FALSE for large datasets

output$errorMsg <- renderText({ " " }) # Initialize errorMsg with empty string
