tabPanel("File upload",
         fluidPage(
           sidebarLayout(
             sidebarPanel(
               h3("Please submit your haplotype"),br(),
               helpText("Optionally type in your haplotype, if you are aware of it."),br(),
               textInput("haplotype", "Your haplotype:", value = "", placeholder = 'e.g. H1b'),
               shinyFilesButton("file", "Browse...", "Upload", multiple = F),br(),
               div(style = "display: inline-block; vertical-align: top; horizontal-align: right; margin: 10px;",
                   tags$i(id = "infoIcon", class = "fa fa-info-circle", style = "font-size: 20px;"),
                   uiOutput("fileTypeInfo")),
               h3("Explore Your mtDNA Heritage"),br(),
               actionButton('goButton',' Explore ',icon('refresh'),width = 180)),
             
             mainPanel(
               add_busy_bar(color = "#FF0000"),
               # Conditional panel that checks if 'setupComplete' is FALSE
               h3("Ancient mtDNA Database"),
               plotOutput("treeDisplay"),
               DTOutput("dataTable"),
               textOutput("errorMsg")
             )
           ),
           tags$head(tags$style(HTML('
              .tooltip-inner {
                  text-transform: none !important; /* Make text sentence case */
                  text-align: center !important; /* Justify text */
              }')
            ))
         ))
