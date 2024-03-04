GO_reactive <- reactive({
  if (input$go_cp %in% comparelist) {
    go_df<-read.delim(paste0("data/",'go.txt'),header=T)
	term2gene_bp <- go_df[go_df[,'go_ontology']=='BP',c('go_id','gene_id')]
	term2name_bp <- go_df[go_df[,'go_ontology']=='BP',c('go_id','go_term')]
	term2gene_cc <- go_df[go_df[,'go_ontology']=='CC',c('go_id','gene_id')]
	term2name_cc <- go_df[go_df[,'go_ontology']=='CC',c('go_id','go_term')]
	term2gene_mf <- go_df[go_df[,'go_ontology']=='MF',c('go_id','gene_id')]
	term2name_mf <- go_df[go_df[,'go_ontology']=='MF',c('go_id','go_term')]

    diffresult <- read.table(paste0("data/",input$go_cp,'_DEG.xls'),header=T,sep="\t")
    diffgene <- subset(diffresult,pvalue<=input$go_p & padj<=input$go_q & abs(log2FoldChange)>=log(input$go_fc,2))
    diffgene_vt <- as.character(diffgene$Gene_ID)
    genename_vt <- as.character(diffgene$GeneName)
    names(genename_vt) <- diffgene_vt
	BPenrich <- enricher(gene=as.character(diffgene[,1]),universe=as.character(diffresult[,1]),TERM2GENE=term2gene_bp,TERM2NAME=term2name_bp,pAdjustMethod='BH',pvalueCutoff=1,qvalueCutoff=1)
    CCenrich <- enricher(gene=as.character(diffgene[,1]),universe=as.character(diffresult[,1]),TERM2GENE=term2gene_cc,TERM2NAME=term2name_cc,pAdjustMethod='BH',pvalueCutoff=1,qvalueCutoff=1)
	MFenrich <- enricher(gene=as.character(diffgene[,1]),universe=as.character(diffresult[,1]),TERM2GENE=term2gene_mf,TERM2NAME=term2name_mf,pAdjustMethod='BH',pvalueCutoff=1,qvalueCutoff=1)

    BPenrichs <- as.data.frame(BPenrich)
    names(BPenrichs)[6] <- 'padj'
    BPenrichs <- subset(BPenrichs,select=-qvalue)
    Category <- rep('BP',time=nrow(BPenrichs))
    BPenrichs <- cbind(Category,BPenrichs)

    CCenrichs <- as.data.frame(CCenrich)
    names(CCenrichs)[6] <- 'padj'
    CCenrichs <- subset(CCenrichs,select=-qvalue)
    Category <- rep('CC',time=nrow(CCenrichs))
    CCenrichs <- cbind(Category,CCenrichs)

    MFenrichs <- as.data.frame(MFenrich)
    names(MFenrichs)[6] <- 'padj'
    MFenrichs <- subset(MFenrichs,select=-qvalue)
    Category <- rep('MF',time=nrow(MFenrichs))
    MFenrichs <- cbind(Category,MFenrichs)
    GOenrichs <- rbind(BPenrichs,CCenrichs,MFenrichs)
    gene_list <- strsplit(GOenrichs$geneID,split='/')
    geneName <- unlist(lapply(gene_list,FUN=function(x){paste(genename_vt[x],collapse='/')}))
    GOenrichs <- data.frame(GOenrichs[,1:8],geneName,GOenrichs[,9,drop=F])
    

    return(list('BPenrich'=BPenrich,'BPenrichs'=BPenrichs,'CCenrich'=CCenrich,'CCenrichs'=CCenrichs,'MFenrich'=MFenrich,'MFenrichs'=MFenrichs,'GOenrichs'=GOenrichs))}})

GO_enrich_reactive <- reactive({
  data <- GO_reactive()
  if (input$go_enrich_type=='BP') {GOsignificant <- subset(data$BPenrichs,pvalue<=input$go_enrich_p & padj<=input$go_enrich_q)}
  if (input$go_enrich_type=='CC') {GOsignificant <- subset(data$CCenrichs,pvalue<=input$go_enrich_p & padj<=input$go_enrich_q)}
  if (input$go_enrich_type=='MF') {GOsignificant <- subset(data$MFenrichs,pvalue<=input$go_enrich_p & padj<=input$go_enrich_q)}
  if (input$go_enrich_type=='ALL') {GOsignificant <- subset(data$GOenrichs,pvalue<=input$go_enrich_p & padj<=input$go_enrich_q)}
  return(list('GOsignificant'=GOsignificant))})

GO_enrich_Reactive <- eventReactive(input$go_enrich_button,{
  data <- GO_reactive()
  if (input$go_enrich_type=='BP') {GOsignificant <- subset(data$BPenrichs,pvalue<=input$go_enrich_p & padj<=input$go_enrich_q)}
  if (input$go_enrich_type=='CC') {GOsignificant <- subset(data$CCenrichs,pvalue<=input$go_enrich_p & padj<=input$go_enrich_q)}
  if (input$go_enrich_type=='MF') {GOsignificant <- subset(data$MFenrichs,pvalue<=input$go_enrich_p & padj<=input$go_enrich_q)}
  if (input$go_enrich_type=='ALL') {GOsignificant <- subset(data$GOenrichs,pvalue<=input$go_enrich_p & padj<=input$go_enrich_q)}
  return(list('GOsignificant'=GOsignificant))})

GO_bar_reactive <- reactive({ 
  data <- GO_reactive()
  if (input$go_bar_type=='BP') {GObarterm <- data$BPenrichs[1:input$go_bar_number,]}
  if (input$go_bar_type=='CC') {GObarterm <- data$CCenrichs[1:input$go_bar_number,]}
  if (input$go_bar_type=='MF') {GObarterm <- data$MFenrichs[1:input$go_bar_number,]}
  if (input$go_bar_type=='ALL') {GObarterm <- rbind(data$BPenrichs[1:input$go_bar_number,],data$CCenrichs[1:input$go_bar_number,],data$MFenrichs[1:input$go_bar_number,])}
  Description <- NULL
  for (i in 1:nrow(GObarterm)) {
    if (nchar(as.character(GObarterm$Description[i])) >= 50) {
      vectors <- unlist(strsplit(as.character(GObarterm$Description[i]),' '))
      Description[i] <- paste(i,'.',vectors[1],vectors[2],vectors[3],vectors[4],'...',sep=' ')}
    if (nchar(as.character(GObarterm$Description[i])) < 50) {
      Description[i] <- paste(i,'.',as.character(GObarterm$Description[i]),sep=' ')}}
  GObarterm$Description <- factor(Description,levels=Description)
  GObarplot <- ggplot(GObarterm,aes(x=Description,y=-log10(padj),fill=Category)) + geom_bar(stat='identity') +
    theme(axis.text.x=element_text(hjust=1,angle=45,size=6)) +
    theme(plot.margin=unit(c(1,1,2,4),'lines')) +
    theme(panel.background=element_rect(fill="transparent"),axis.line=element_line())
  return(list('GObarplot'=GObarplot))})

GO_bar_Reactive <- eventReactive(input$go_bar_button,{
  data <- GO_reactive()
  if (input$go_bar_type=='BP') {GObarterm <- data$BPenrichs[1:input$go_bar_number,]}
  if (input$go_bar_type=='CC') {GObarterm <- data$CCenrichs[1:input$go_bar_number,]}
  if (input$go_bar_type=='MF') {GObarterm <- data$MFenrichs[1:input$go_bar_number,]}
  if (input$go_bar_type=='ALL') {GObarterm <- rbind(data$BPenrichs[1:input$go_bar_number,],data$CCenrichs[1:input$go_bar_number,],data$MFenrichs[1:input$go_bar_number,])}
  Description <- NULL
  for (i in 1:nrow(GObarterm)) {
    if (nchar(as.character(GObarterm$Description[i])) >= 50) {
      vectors <- unlist(strsplit(as.character(GObarterm$Description[i]),' '))
      Description[i] <- paste(i,'.',vectors[1],vectors[2],vectors[3],vectors[4],'...',sep=' ')}
    if (nchar(as.character(GObarterm$Description[i])) < 50) {
      Description[i] <- paste(i,'.',as.character(GObarterm$Description[i]),sep=' ')}}
  GObarterm$Description <- factor(Description,levels=Description)
  GObarplot <- ggplot(GObarterm,aes(x=Description,y=-log10(padj),fill=Category)) + geom_bar(stat='identity') +
    theme(axis.text.x=element_text(hjust=1,angle=45,size=6)) +
    theme(plot.margin=unit(c(1,1,2,4),'lines')) +
    theme(panel.background=element_rect(fill="transparent"),axis.line=element_line())
  return(list('GObarplot'=GObarplot))})

GO_dot_reactive <- reactive({
  data <- GO_reactive()
  if (input$go_dot_type=='BP') {GOdotterm <- data$BPenrichs[1:input$go_dot_number,]}
  if (input$go_dot_type=='CC') {GOdotterm <- data$CCenrichs[1:input$go_dot_number,]}
  if (input$go_dot_type=='MF') {GOdotterm <- data$MFenrichs[1:input$go_dot_number,]}
  if (input$go_dot_type=='ALL') {GOdotterm <- rbind(data$BPenrichs[1:input$go_dot_number,],data$CCenrichs[1:input$go_dot_number,],data$MFenrichs[1:input$go_dot_number,])}
  Description <- NULL
  for (i in 1:nrow(GOdotterm)) {
    if ( nchar(as.character(GOdotterm$Description[i])) >= 50) {
      vectors <- unlist(strsplit(as.character(GOdotterm$Description[i]),' '))
      Description[i] <- paste(i,'.',vectors[1],vectors[2],vectors[3],vectors[4],'...',sep=' ')}
    if ( nchar(as.character(GOdotterm$Description[i])) < 50) {
      Description[i] <- paste(i,'.',as.character(GOdotterm$Description[i]),sep=' ')}}
  GOdotterm$Description <- factor(Description,levels=Description)
  ratio <- matrix(as.numeric(unlist(strsplit(as.vector(GOdotterm$GeneRatio),"/"))),ncol=2,byrow=TRUE)
  GOdotterm$GeneRatio <- ratio[,1]/ratio[,2]
  GOdotplot <- ggplot(GOdotterm,aes(x=GeneRatio,y=Description,colour=padj,size=Count))+geom_point()+scale_colour_gradientn(colours=rainbow(4),guide="colourbar")+expand_limits(color=seq(0,1,by=0.25))+xlab("GeneRatio")+ylab("")+theme_bw()+theme(axis.text=element_text(color="black",size=10))+theme(panel.border=element_rect(colour="black"))+theme(plot.title=element_text(vjust=1),legend.key=element_blank())
  return(list('GOdotplot'=GOdotplot))})

GO_dot_Reactive <- eventReactive(input$go_dot_button,{
  data <- GO_reactive()
  if (input$go_dot_type=='BP') {GOdotterm <- data$BPenrichs[1:input$go_dot_number,]}
  if (input$go_dot_type=='CC') {GOdotterm <- data$CCenrichs[1:input$go_dot_number,]}
  if (input$go_dot_type=='MF') {GOdotterm <- data$MFenrichs[1:input$go_dot_number,]}
  if (input$go_dot_type=='ALL') {GOdotterm <- rbind(data$BPenrichs[1:input$go_dot_number,],data$CCenrichs[1:input$go_dot_number,],data$MFenrichs[1:input$go_dot_number,])}
  Description <- NULL
  for (i in 1:nrow(GOdotterm)) {
    if ( nchar(as.character(GOdotterm$Description[i])) >= 50) {
      vectors <- unlist(strsplit(as.character(GOdotterm$Description[i]),' '))
      Description[i] <- paste(i,'.',vectors[1],vectors[2],vectors[3],vectors[4],'...',sep=' ')}
    if ( nchar(as.character(GOdotterm$Description[i])) < 50) {
      Description[i] <- paste(i,'.',as.character(GOdotterm$Description[i]),sep=' ')}}
  GOdotterm$Description <- factor(Description,levels=Description)
  ratio <- matrix(as.numeric(unlist(strsplit(as.vector(GOdotterm$GeneRatio),"/"))),ncol=2,byrow=TRUE)
  GOdotterm$GeneRatio <- ratio[,1]/ratio[,2]
  GOdotplot <- ggplot(GOdotterm,aes(x=GeneRatio,y=Description,colour=padj,size=Count))+geom_point()+scale_colour_gradientn(colours=rainbow(4),guide="colourbar")+expand_limits(color=seq(0,1,by=0.25))+xlab("GeneRatio")+ylab("")+theme_bw()+theme(axis.text=element_text(color="black",size=10))+theme(panel.border=element_rect(colour="black"))+theme(plot.title=element_text(vjust=1),legend.key=element_blank())
  return(list('GOdotplot'=GOdotplot))})

GO_dag_reactive <- reactive({
  data <- GO_reactive()
  if (input$go_dag_type=='BP') {
  data$BPenrich@ontology<-'BP'
  GOdagplot <- plotGOgraph(x=data$BPenrich,firstSigNodes=input$go_dag_number)}
  if (input$go_dag_type=='CC') {
  data$CCenrich@ontology<-'CC'
  GOdagplot <- plotGOgraph(x=data$CCenrich,firstSigNodes=input$go_dag_number)}
  if (input$go_dag_type=='MF') {
  data$MFenrich@ontology<-'MF'
  GOdagplot <- plotGOgraph(x=data$MFenrich,firstSigNodes=input$go_dag_number)}
  return(list('GOdagplot'=GOdagplot))})

GO_dag_Reactive <- eventReactive(input$go_dag_button,{
  data <- GO_reactive()
  if (input$go_dag_type=='BP') {
  data$BPenrich@ontology<-'BP'
  GOdagplot <- plotGOgraph(x=data$BPenrich,firstSigNodes=input$go_dag_number)}
  if (input$go_dag_type=='CC') {
  data$CCenrich@ontology<-'CC'
  GOdagplot <- plotGOgraph(x=data$CCenrich,firstSigNodes=input$go_dag_number)}
  if (input$go_dag_type=='MF') {
  data$MFenrich@ontology<-'MF'
  GOdagplot <- plotGOgraph(x=data$MFenrich,firstSigNodes=input$go_dag_number)}
  return(list('GOdagplot'=GOdagplot))})

#output

output$go_enrich <- DT::renderDataTable({
  data <- GO_enrich_Reactive()
  datatable(data$GOsignificant,rownames=FALSE,extensions=c('KeyTable','FixedColumns'),options=list(keys=T,scrollX=T))})

output$go_enrich_download <- downloadHandler(
  filename='go_enrich.txt',
  content = function(file) {
  data <- GO_enrich_reactive()
  write.table(data$GOsignificant,file,row.names=FALSE,sep='\t',quote=FALSE)})

output$go_bar <- renderPlot({
  data <- GO_bar_Reactive()
  data$GObarplot})

output$go_bar_download <- downloadHandler(
  filename='GObar.pdf',
  content = function(file) {
  pdf(file)
  data <- GO_bar_reactive()
  plot(data$GObarplot)
  dev.off()})

output$go_dot <- renderPlot({
  data <- GO_dot_Reactive()
  data$GOdotplot})

output$go_dot_download <- downloadHandler(
  filename='GOdot.pdf',
  content = function(file) {
  pdf(file)
  data <- GO_dot_reactive()
  plot(data$GOdotplot)
  dev.off()})

output$go_dag <- renderPlot({
  data <-GO_dag_Reactive()
  data$GOdagplot})

output$go_dag_download <- downloadHandler(
  filename='GOdag.pdf',
  content = function(file) {
  pdf(file)
  data <- GO_dag_reactive()
  data$GOdagplot
  dev.off()})
