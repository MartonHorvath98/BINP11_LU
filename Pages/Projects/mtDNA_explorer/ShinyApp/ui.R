source("helpers.R")
shinyUI(tagList(
fillPage(theme=shinythemes::shinytheme("sandstone"),
         tags$style(type='text/css', '.selectize-input { font-size: 32px; }'),
          titlePanel(h1(id="header", "mtDNA Heritage Explorer"),
                     tags$h1(type="text/css", "#header {background-color: #222222; color: #FFFFFF;
                                font-size: 20px; font-weight: bold; align: center; left-padding: 100px;}")),
          source("ui-inread.R",local=T)$value #,
          # source("ui-degs.R", local=T)$value,
          # source("ui-diff.R",local=T)$value,
          # source("ui-go.R",local=T)$value,
          # source("ui-kegg.R",local=T)$value
)))
