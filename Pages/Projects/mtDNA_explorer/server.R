shinyServer(function(input, output, session){
    session$onSessionEnded(function() {
        stopApp()
})
})

setupComplete <- FALSE
reference <- seqinr::read.fasta('data/ref/rCRS.fasta')
# load mutational data from AmtDB
mutations <- read.table("./data/AmtDB/mutations.txt", 
                        quote = "", header = TRUE, sep = "\t",
                        stringsAsFactors = FALSE)
haplo_tree <- NULL

options(shiny.maxRequestSize=1024^10)
source("ShinyApp/helpers.R")
#source("ShinyApp/workflow.R")


shinyServer(function(input,output,session) {
  source("ShinyApp/server-inread.R",local=T)
  # source("server-degs.R", local=T)
  # source("server-diff.R",local=T)
  # source("server-go.R",local=T)
  # source("server-kegg.R",local=T)
})
