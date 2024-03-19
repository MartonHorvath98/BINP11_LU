# dir
volumes <- getVolumes()()
volumes <- c(volumes)
shinyFileChoose(input, 'file', roots = volumes, session = session,
                 filetypes = c('tsv', 'txt', 'fasta'))


dirselect_Reactive <- reactive({
  dir <- input$dir
  path <- parseDirPath(roots = volumes, selection = dir)
  infiles <- list.files(path = path, pattern = ".bam$", full.names = T)
  bamfiles <- BamFileList(infiles, yieldSize = 2000000)
  return(list("path"=path, "files"= bamfiles))
})

count_Reactive <- eventReactive(input$count_button,{
  return(list("count_table" = mutation.df))
  }
)

output$dir <- renderPrint(dirselect_Reactive()$path)
output$files <- renderPrint(dirselect_Reactive()$files)

output$count_table <- renderDataTable({
  data <- count_Reactive()
  datatable(data$count_table, rownames=TRUE, options=list(keys=T,scrollX=T))
})
