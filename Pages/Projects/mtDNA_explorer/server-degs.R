# Event listeners
observeEvent(input$treatment, {
  updateTabsetPanel(inputId = "params", selected = input$treatment)
})

observeEvent(input$load_counts_button,{
  all_conditions$df <- data.frame(matrix(data = '', nrow = 5, ncol = dim(load_counts_Reactive()$readcounts)[2]))
  colnames(all_conditions$df) <- colnames(load_counts_Reactive()$readcounts)
})

observeEvent(input$save_condition,{
  data <- all_conditions$df
  write.table(data, "data/conditions.txt", sep = "\t", row.names = T, col.names = T)
})


load_counts_Reactive <- reactive({
  if(req(fpkm)) {return(list('readcounts'= fpkm))}})

load_counts_Reactive <- eventReactive(input$load_counts_button,{
  infile <- input$load_counts
  if(!is.null(infile)) {
    readcounts <- read.table(infile$datapath, header=T, sep='\t', row.names = 1)
    return(list('readcounts'= readcounts))}})

all_conditions <- reactiveValues(df = NULL)



add_condition <- eventReactive(input$add_condition,{
  infile <- input$load_counts
  
  if(!is.null(infile)) {
    tmp <- all_conditions$df
    cols <- c(input$readcounts_columns_selected)
    lengthy <- length(cols)
    
    sample <- switch(input$treatment,
      Infection = c(input$agent1, input$dose, input$time1),
      Evolution = c(input$agent2, input$mic, input$time2)
    )
    
    df <- c(as.factor(c(rep(sample[1], lengthy))),
                     as.factor(c(rep(sample[2], lengthy))),
                     as.factor(c(rep(sample[3], lengthy))),
                     as.factor(c(paste0("run", seq(1,lengthy)))))
    df <- data.frame(matrix(df, ncol = lengthy, byrow = T))
    df <- rbind(df, lapply(c(df[1:3,]), paste0, collapse="_"))
    
    
    tmp[,cols] <- df
    rows <- switch(input$treatment,
                     Infection = c("Treatment", "Dose", "Time", "Run", "Condition"),
                     Evolution = c("Treatment", "MIC", "Time", "Run", "Condition")
    )

    row.names(tmp) <- rows
    all_conditions$df <- tmp
    return(list("conditions"= all_conditions$df))
  }})


#output
output$readcounts <- renderDT({
    data <- load_counts_Reactive()$readcounts
    datatable(data, selection = list(target = 'column', selectable =c(-0)),extensions=c('FixedColumns'),
              options=list(dom='t', ordering = F, scrollX=T))
  })

output$conditions <- renderDT({
  data <- add_condition()$conditions
  datatable(data, extensions=c('FixedColumns'), options = list(dom = 't', ordering = F, scrollX = T))
  })

output$tool_annotation_download <- downloadHandler(
  filename='annotation_table.txt',
  content = function(file) {
    data <- tool_annotation_Reactive()
    write.table(data$annotation_table,file,row.names=FALSE,sep='\t',quote=FALSE)})

output$tool_heatmap_pdf <- renderPlot({tool_heatmap_Reactive()$Heatmap})

output$tool_heatmap_download_pdf <- downloadHandler(
  filename='heatmap_table.pdf',
  content = function(file) {
    pdf(file,onefile=F)
    tool_heatmap_reactive()$Heatmap
    dev.off()})

output$tool_heatmap_download_txt <- downloadHandler(
  filename='heatmap_table.txt',
  content = function(file) {
    data <- tool_heatmap_Reactive()
    write.table(data.frame(ID=rownames(data$heatmap_table),data$heatmap_table),file,row.names=FALSE,sep='\t',quote=FALSE)})
