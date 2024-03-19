fluidPage(
  sidebarLayout(
    sidebarPanel(h3("Choose a sample file"),br(),
                 shinyFilesButton(id = "file", title = "Browse...", label = "Load",
                                  multiple = F, buttonType = "default"),
                 helpText('Load input files in fasta format, or containing a list of mutations,
                          formatted as chr:pos:ref:alt.'),
                 # choose threshold of information content for accepting a mutation
                 sliderInput("threshold", "Threshold for information content", 
                             min = 0, max = 2, value = 1.5, step = 0.05),
                 helpText('Please select how strict the threshold should be, to decide
                          which SNPs to keep for the prediction.'), br(),
                 h3("Predict haplotype"),br(),
                 actionButton('count_button',' Start prediction ',icon('refresh'),width = 180),br()),
    
    mainPanel(
      add_busy_bar(color = "#FF0000"),
      #verbatimTextOutput('dir'),br(),
      #verbatimTextOutput('files'),br(),
      dataTableOutput('count_table'))))
