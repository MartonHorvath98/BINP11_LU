shinyServer(function(input, output, session){
    session$onSessionEnded(function() {
        stopApp()
})
})

options(shiny.maxRequestSize=1024^10)
source("helpers.R")
shinyServer(function(input,output,session) {
  source("server-inread.R",local=T)
  # source("server-degs.R", local=T)
  # source("server-diff.R",local=T)
  # source("server-go.R",local=T)
  # source("server-kegg.R",local=T)
})
