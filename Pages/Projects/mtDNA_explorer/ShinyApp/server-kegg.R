KEGG_reactive <- reactive({
  if (input$kegg_cp %in% comparelist) {
	kegg_df<-read.delim(paste0("data/",'kegg.txt'),header=T)
	term2gene <- kegg_df[,c('pathway_id','gene_id')]
	term2name <- kegg_df[,c('pathway_id','pathway_name')]
    diffresult <- read.table(paste0("data/",input$kegg_cp,'_DEG.xls'),header=T,sep="\t")
    diffgene <- subset(diffresult,pvalue<=input$kegg_p & padj<=input$kegg_q & abs(log2FoldChange)>=log(input$kegg_fc,2))
    foldchange <- diffgene[,"log2FoldChange"]
    diffgene_vt <- as.character(diffgene$Gene_ID)
    genename_vt <- as.character(diffgene$GeneName)
    names(genename_vt) <- diffgene_vt
    #ID <- bitr(as.character(diffgene[,1]),fromType="ENSEMBL",toType="ENTREZID",OrgDb=orgdb)[,1]
    #backgene <- bitr(as.character(diffresult[,1]),fromType="ENSEMBL",toType="ENTREZID",OrgDb=orgdb)[,2]
    #diffgene <- bitr(as.character(diffgene[,1]),fromType="ENSEMBL",toType="ENTREZID",OrgDb=orgdb)[,2]
    #foldchange <- foldchange[ID]
    names(foldchange) <- diffgene
    foldchange <- sort(foldchange,decreasing = TRUE)
    KEGGenrich <- enricher(gene=as.character(diffgene[,1]),universe=as.character(diffresult[,1]),TERM2GENE=term2gene,TERM2NAME=term2name,pAdjustMethod='BH',pvalueCutoff=1,qvalueCutoff=1)
    #KEGGenrich <- enrichKEGG(gene=diffgene,universe=backgene,organism=organism,pAdjustMethod='BH',pvalueCutoff=1,qvalueCutoff=1,use_internal_data=F)
    KEGGenrichs <- as.data.frame(KEGGenrich)
    names(KEGGenrichs)[6] <- 'padj'
    KEGGenrichs <- subset(KEGGenrichs,select=-qvalue)
    Category <- rep('KEGG',time=nrow(KEGGenrichs))
    
    gene_list <- strsplit(KEGGenrichs$geneID,split='/')
    geneName <- unlist(lapply(gene_list,FUN=function(x){paste(genename_vt[x],collapse='/')}))
    KEGGenrichs <- data.frame(KEGGenrichs[,1:7],geneName,KEGGenrichs[,8,drop=F])
    KEGGenrichs <- cbind(Category,KEGGenrichs)
    return(list('KEGGenrich'=KEGGenrich,'KEGGenrichs'=KEGGenrichs,'foldchange'=foldchange))}})
	  #return(list('KEGGenrich'=KEGGenrich,'KEGGenrichs'=KEGGenrichs))}})

KEGG_enrich_reactive <- reactive({
  data <- KEGG_reactive()
  KEGGsignificant <- subset(data$KEGGenrichs,pvalue<=input$kegg_enrich_p & padj<=input$kegg_enrich_q)
  return(list('KEGGsignificant'=KEGGsignificant))})

KEGG_enrich_Reactive <- eventReactive(input$kegg_enrich_button,{
  data <- KEGG_reactive()
  KEGGsignificant <- subset(data$KEGGenrichs,pvalue<=input$kegg_enrich_p & padj<=input$kegg_enrich_q)
  return(list('KEGGsignificant'=KEGGsignificant))})

KEGG_bar_reactive <- reactive({
  data <- KEGG_reactive()
  KEGGbarterm <- data$KEGGenrichs[1:input$kegg_bar_number,]
  Description <- NULL
    for (i in 1:nrow(KEGGbarterm)) {
      if (nchar(as.character(KEGGbarterm$Description[i])) >= 50) {
        vectors <- unlist(strsplit(as.character(KEGGbarterm$Description[i]),' '))
        Description[i] <- paste(vectors[1],vectors[2],vectors[3],vectors[4],'...',sep=' ')}
      if (nchar(as.character(KEGGbarterm$Description[i])) < 50) {
        Description[i] <- as.character(KEGGbarterm$Description[i])}}
  KEGGbarterm$Description <- factor(Description,levels=Description)
  KEGGbarplot <- ggplot(KEGGbarterm,aes(x=Description,y=-log10(padj),fill=Category)) + geom_bar(stat='identity') +
    theme(axis.text.x=element_text(hjust=1,angle=45,size=6)) +
    theme(plot.margin=unit(c(1,1,2,4),'lines')) +
    theme(legend.position="none") +
    theme(panel.background=element_rect(fill="transparent"),axis.line=element_line())
  return(list('KEGGbarplot'=KEGGbarplot))})

KEGG_bar_Reactive <- eventReactive(input$kegg_bar_button,{
  data <- KEGG_reactive()
  KEGGbarterm <- data$KEGGenrichs[1:input$kegg_bar_number,]
  Description <- NULL
    for (i in 1:nrow(KEGGbarterm)) {
      if (nchar(as.character(KEGGbarterm$Description[i])) >= 50) {
        vectors <- unlist(strsplit(as.character(KEGGbarterm$Description[i]),' '))
        Description[i] <- paste(vectors[1],vectors[2],vectors[3],vectors[4],'...',sep=' ')}
      if (nchar(as.character(KEGGbarterm$Description[i])) < 50) {
        Description[i] <- as.character(KEGGbarterm$Description[i])}}
  KEGGbarterm$Description <- factor(Description,levels=Description)
  KEGGbarplot <- ggplot(KEGGbarterm,aes(x=Description,y=-log10(padj),fill=Category)) + geom_bar(stat='identity') +
    theme(axis.text.x=element_text(hjust=1,angle=45,size=6)) +
    theme(plot.margin=unit(c(1,1,2,4),'lines')) +
    theme(legend.position="none") +
    theme(panel.background=element_rect(fill="transparent"),axis.line=element_line())
  return(list('KEGGbarplot'=KEGGbarplot))})

KEGG_dot_reactive <- reactive({
  data <- KEGG_reactive()
  KEGGdotterm <- data$KEGGenrichs[1:input$kegg_dot_number,]
  Description <- NULL
  for (i in 1:nrow(KEGGdotterm)) {
    if (nchar(as.character(KEGGdotterm$Description[i])) >= 50) {
      vectors <- unlist(strsplit(as.character(KEGGdotterm$Description[i]),' '))
      Description[i] <- paste(vectors[1],vectors[2],vectors[3],vectors[4],'...',sep=' ')}
    if ( nchar(as.character(KEGGdotterm$Description[i])) < 50) {
      Description[i] <- as.character(KEGGdotterm$Description[i])}}
  KEGGdotterm$Description <- factor(Description,levels=Description)
  ratio <- matrix(as.numeric(unlist(strsplit(as.vector(KEGGdotterm$GeneRatio),"/"))),ncol=2,byrow=TRUE)
  KEGGdotterm$GeneRatio <- ratio[,1]/ratio[,2]
  KEGGdotplot <- ggplot(KEGGdotterm,aes(x=GeneRatio,y=Description,colour=padj,size=Count))+geom_point()+scale_colour_gradientn(colours=rainbow(4),guide="colourbar")+expand_limits(color=seq(0,1,by=0.25))+xlab("GeneRatio")+ylab("")+theme_bw()+theme(axis.text=element_text(color="black",size=10))+theme(panel.border=element_rect(colour="black"))+theme(plot.title=element_text(vjust=1),legend.key=element_blank())
  return(list('KEGGdotplot'=KEGGdotplot))})

KEGG_dot_Reactive <- eventReactive(input$kegg_dot_button,{
  data <- KEGG_reactive()
  KEGGdotterm <- data$KEGGenrichs[1:input$kegg_dot_number,]
  Description <- NULL
  for (i in 1:nrow(KEGGdotterm)) {
    if (nchar(as.character(KEGGdotterm$Description[i])) >= 50) {
      vectors <- unlist(strsplit(as.character(KEGGdotterm$Description[i]),' '))
      Description[i] <- paste(vectors[1],vectors[2],vectors[3],vectors[4],'...',sep=' ')}
    if ( nchar(as.character(KEGGdotterm$Description[i])) < 50) {
      Description[i] <- as.character(KEGGdotterm$Description[i])}}
  KEGGdotterm$Description <- factor(Description,levels=Description)
  ratio <- matrix(as.numeric(unlist(strsplit(as.vector(KEGGdotterm$GeneRatio),"/"))),ncol=2,byrow=TRUE)
  KEGGdotterm$GeneRatio <- ratio[,1]/ratio[,2]
  KEGGdotplot <- ggplot(KEGGdotterm,aes(x=GeneRatio,y=Description,colour=padj,size=Count))+geom_point()+scale_colour_gradientn(colours=rainbow(4),guide="colourbar")+expand_limits(color=seq(0,1,by=0.25))+xlab("GeneRatio")+ylab("")+theme_bw()+theme(axis.text=element_text(color="black",size=10))+theme(panel.border=element_rect(colour="black"))+theme(plot.title=element_text(vjust=1),legend.key=element_blank())
  return(list('KEGGdotplot'=KEGGdotplot))})

KEGG_pathwayid <- eventReactive(input$kegg_id_button,{
  data <- KEGG_reactive()
  KEGGpathwayid <- subset(data$KEGGenrichs,pvalue<=input$kegg_enrich_p & padj<=input$kegg_enrich_q)[,c('ID','Description','pvalue','padj')]
  return(list('KEGGpathwayid'=KEGGpathwayid))})

KEGG_pathway <- eventReactive(input$kegg_pathway_button,{
  data <- KEGG_reactive()
  browse <- browseKEGG(data$KEGGenrich,input$kegg_pathway_id)
  return(list('browse'=browse))})

#output

output$kegg_enrich <- DT::renderDataTable({
  data <- KEGG_enrich_Reactive()
  datatable(data$KEGGsignificant,rownames=FALSE,extensions=c('KeyTable','FixedColumns'),options=list(keys=T,scrollX=T))})

output$kegg_enrich_download <- downloadHandler(
  filename='kegg_enrich.txt',
  content = function(file) {
  data <- KEGG_enrich_reactive()
  write.table(data$KEGGsignificant,file,row.names=FALSE,sep='\t',quote=FALSE)})

output$kegg_bar <- renderPlot({
  data <- KEGG_bar_Reactive()
  data$KEGGbarplot})

output$kegg_bar_download <- downloadHandler(
  filename='KEGGbar.pdf',
  content = function(file) {
  pdf(file)
  data <- KEGG_bar_reactive()
  plot(data$KEGGbarplot)
  dev.off()})

output$kegg_dot <- renderPlot({
  data <- KEGG_dot_Reactive()
  data$KEGGdotplot})

output$kegg_dot_download <- downloadHandler(
  filename='KEGGdot.pdf',
  content = function(file) {
  pdf(file)
  data <- KEGG_dot_reactive()
  plot(data$KEGGdotplot)
  dev.off()})

output$kegg_pathwayid <- renderTable({
  data <- KEGG_pathwayid()
  data$KEGGpathwayid})

output$kegg_pathway <- renderPlot({
  data <- KEGG_pathway()
  data$browse})
