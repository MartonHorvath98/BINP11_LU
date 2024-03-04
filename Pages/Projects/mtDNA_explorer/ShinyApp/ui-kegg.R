tabPanel("KEGG Enrichment",
  fluidRow(
    column(3,wellPanel(
      conditionalPanel('input.keggtype=="KEGG enrichment"',
        radioButtons(inputId='kegg_cp',label='Compare Group',choices=comparelist,selected=comparelist[1]),
        helpText('Choose a compare group'),
        numericInput(inputId='kegg_fc',label='Fold Change',value=1,width=200),
        numericInput(inputId='kegg_p',label='P-value',value=0.05,min=0,max=1,step=0.01,width=200),
        numericInput(inputId='kegg_q',label='Padj value',value=0.05,min=0,max=1,step=0.01,width=200),
        numericInput(inputId='kegg_enrich_p',label='Enrichment P-value',value=0.05,min=0,max=1,step=0.01,width=200),
        numericInput(inputId='kegg_enrich_q',label='Enrichment padj value',value=0.05,min=0,max=1,step=0.01,width=200),
        actionButton("kegg_enrich_button","Show",icon('refresh'),width = 118),br(),
        helpText('Please wait for a moment, do not click repeatedly.'),
        downloadButton("kegg_enrich_download",label="Download")),

      conditionalPanel('input.keggtype=="KEGG bar"',
        numericInput(inputId='kegg_bar_number',label='KEGG bar number',value=20,width=200),
        helpText('Input the number of desired bins in histogram. If error occurs, please adjust to the default number of 20.'),
        actionButton("kegg_bar_button","Show",icon('refresh'),width = 118),br(),
        helpText('Please wait for a moment, do not click repeatedly.'),
        downloadButton("kegg_bar_download",label="Download")),

      conditionalPanel('input.keggtype=="KEGG dot"',
        numericInput(inputId='kegg_dot_number',label='KEGG dot number',value=20,width=200),
        helpText('Input the number of desired scatterplot points. If error occurs, please adjust to the default number of 20.'),
        actionButton("kegg_dot_button","Show",icon('refresh'),width = 118),br(),
        helpText('Please wait for a moment, do not click repeatedly.'),
        downloadButton("kegg_dot_download",label="Download")),

      conditionalPanel('input.keggtype=="KEGG pathway"',
        textInput(inputId='kegg_pathway_id',label='KEGG pathway ID',value=NULL,width=200),
        helpText('KEGG ID'),
        actionButton("kegg_id_button","Show ID",icon('refresh'),width = 118),
        helpText('Please wait for a moment, do not click repeatedly.'),
        actionButton("kegg_pathway_button","show pathway",icon('refresh')),
        helpText('Please wait for a moment, do not click repeatedly.')))),

    mainPanel(
      tabsetPanel(id='keggtype',
        tabPanel(title="KEGG enrichment",br(),dataTableOutput('kegg_enrich')),
        tabPanel(title="KEGG bar",br(),plotOutput("kegg_bar",width=600,height=480)),
        tabPanel(title="KEGG dot",br(),plotOutput("kegg_dot",width=600,height=480)),
        tabPanel(title="KEGG pathway",br(),tableOutput('kegg_pathwayid'),plotOutput('kegg_pathway'))))))
