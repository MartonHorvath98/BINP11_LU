tabPanel("File upload",
         fluidPage(
           sidebarLayout(
             sidebarPanel(h3("Choose a directory"),br(),
                          shinyDirButton("dir", "Browse...", "Upload"),
                          helpText('Please choose an input directory.'),
                          h3("Choose a calculation method"),br(),
                          radioButtons("calc", "Choose:", c("Serial" = "serial", "Parallel" = "parallel")),
                          helpText('If you have at least 16Gb Ram and 8 Processor cores you can choose parallel computing, 
                                   otherwise serial computing is strongly advised!'),br(),
                          h3("Count reads"),br(),
                          actionButton('count_button',' Count reads ',icon('refresh'),width = 180),br(),
                          helpText('Please wait for a moment, calculation will take time (up to several minutes), do not click repeatedly.'),
                          h3("Download readcounts"),br(),
                          downloadButton("count_download",label="Download")),
           
           mainPanel(
             add_busy_bar(color = "#FF0000"),
             verbatimTextOutput('dir'),br(),
             verbatimTextOutput('files'),br(),
             dataTableOutput('count_table')))))
