source("ShinyApp/helpers.R")
shinyUI(tagList(
navbarPage(title="mtDNA Heritage explorer",
           theme=shinythemes::shinytheme("sandstone"),
           tags$style(type='text/css', '.selectize-input { font-size: 32px; }'),
           source("ShinyApp/ui-inread.R",local=T)$value #,
          # source("ui-degs.R", local=T)$value,
          # source("ui-diff.R",local=T)$value,
          # source("ui-go.R",local=T)$value,
          # source("ui-kegg.R",local=T)$value)
)))
