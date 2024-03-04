# dir
volumes <- getVolumes()()
volumes <- c(volumes)
shinyDirChoose(input, 'dir', roots = volumes, session = session)


dirselect_Reactive <- reactive({
  dir <- input$dir
  path <- parseDirPath(roots = volumes, selection = dir)
  infiles <- list.files(path = path, pattern = ".bam$", full.names = T)
  bamfiles <- BamFileList(infiles, yieldSize = 2000000)
  return(list("path"=path, "files"= bamfiles))
})

count_Reactive <- eventReactive(input$count_button,{
  dir <- input$dir
  path <- parseDirPath(roots = volumes, selection = dir)
  infiles <- list.files(path = path, pattern = ".bam$", full.names = T)
  bamfiles <- BamFileList(infiles, yieldSize = 2000000)
  
  if(!length(bamfiles)==0){
    txdb <- makeTxDbFromGFF("./data/Homo_sapiens.GRCh38.96.gff3", dataSource = "Ensembl", organism = "Homo sapiens")
    genes <- exonsBy(txdb, by = "gene")
    
    my_register <- switch (input$calc,
      serial = SerialParam(),
      parallel = SnowParam(workers = snowWorkers(type = "SOCK"))
    )
    
    register(my_register)
    reads <- summarizeOverlaps(features = genes, reads = bamfiles, mode = "Union", ignore.strand = F, singleEnd = F, 
                               fragments = T, preprocess.reads = invertStrand)
    
    counts <- assay(reads)
    write.table(counts, "data/counts.txt", sep = "\t", dec = ".", row.names = T, col.names = T)
    return(list("count_table" = counts))
  }
})

output$dir <- renderPrint(dirselect_Reactive()$path)
output$files <- renderPrint(dirselect_Reactive()$files)

output$count_table <- renderDataTable({
  data <- count_Reactive()
  datatable(data$count_table, rownames=TRUE, options=list(keys=T,scrollX=T))
})
