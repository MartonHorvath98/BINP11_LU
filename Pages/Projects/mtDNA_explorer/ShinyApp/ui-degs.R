tabPanel("Differential expression",
         fluidPage(
            sidebarLayout(
              sidebarPanel(
                conditionalPanel('input.degtype=="Readcounts"',
                                 h3('Readcounts'),br(),
                                 actionButton('show_readcounts', 'Show readcounts', icon('refresh', width = "140px")),br(),
                                 helpText("Load the previously calculated readcounts."),br(),
                                 checkboxInput("search_counts", "Load readcounts", value = F),
                                 helpText("Check box, to load readcounts from somewhere else on the computer."),
                                 conditionalPanel(
                                   condition = 'input.search_counts == 1',
                                   fileInput(
                                     inputId='load_counts', label='Readcounts',multiple=FALSE,accept=c('text/plain/xls'),width=250
                                   ),
                                   helpText('Upload gene counts as a list, in .txt format.'),
                                   actionButton("load_counts_button","Show",icon('refresh'),width = 118),br(),
                                   helpText('Please wait for a moment, do not click repeatedly.')
                                 ),
                                 h3('Conditions'),br(),
                                 selectInput("treatment", "Treatment", width = "200px",
                                             choices = c("Infection", "Evolution")
                                 ),
                                 tabsetPanel(
                                   id = "params",
                                   type = "hidden",
                                   tabPanel("Infection",
                                            textInput("agent1", "Infectious agent: ", value = "", width = "200px"),
                                            textInput("dose",  "Infection dose: ", value = "", width = "200px", placeholder = "MOI - (host:pathogene)"),
                                            textInput("time1", "Infection time: ", value = "", width = "200px", placeholder = "hour(S)")),
                                   tabPanel("Evolution",
                                            textInput("agent2", "Evolution: ", value = "", width = "200px"),
                                            textInput("mic", "MIC: ", value = "", width = "200px"),
                                            textInput("time2", "Time: ", value = "", width = "200px", placeholder = "hour(s)"))
                                 ),
                                 actionButton("add_condition", "Add", icon("save"), width = "118px"),br()
                ),
                conditionalPanel('input.degtype=="Differential expression"',
                                 h3("Choose a comparison"),
                                 #radioButtons(inputId='degs_cp',label='Comparison Group',choices=comparelist,selected=comparelist[1]),
                                 #helpText('Choose one group'),
                                 #numericInput(inputId='degs_fc',label='Fold Change',value=1,width=200),
                                 #numericInput(inputId='degs_p',label='P-value',value=0.05,min=0,max=1,step=0.01,width=200),
                                 #numericInput(inputId='degs_q',label='Padj value',value=0.05,min=0,max=1,step=0.01,width=200),
                                 #actionButton('degs_button','Show',icon('refresh'),width = 118),br(),
                                 #helpText('Please wait for a moment, do not click repeatedly.'),
                                 #downloadButton("degs_download",label="Download")
                                 )
              ),
              
              mainPanel(
                tabsetPanel(id='degtype',
                            tabPanel(title="Readcounts",br(),
                                     DTOutput('readcounts'),br(),
                                     DTOutput('conditions')),
                            tabPanel(title="Differential expression",br(),plotOutput('tool_heatmap_pdf')))
              )
              )
            )
         )
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
