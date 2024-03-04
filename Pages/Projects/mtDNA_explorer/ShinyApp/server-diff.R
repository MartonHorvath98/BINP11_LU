Diff_reactive <- reactive({
  if(input$diff_cp %in% comparelist) {
    print(comparelist)
    diffresult <- read.table(paste0("data/",input$diff_cp,'_DEG.xls'),header=T,sep="\t")
    diffgene <- subset(diffresult,pvalue<=input$diff_p & padj<=input$diff_q & abs(log2FoldChange)>=log(input$diff_fc,2))
    return(list('Diffresult'=diffresult,'Diffgene'=diffgene))}})

Diff_Reactive <- eventReactive(input$diff_button,{
  if(input$diff_cp %in% comparelist) {
    diffresult <- read.table(paste0("data/",input$diff_cp,'_DEG.xls'),header=T,sep="\t")
    diffgene <- subset(diffresult,pvalue<=input$diff_p & padj<=input$diff_q & abs(log2FoldChange)>=log(input$diff_fc,2))
    return(list('Diffresult'=diffresult,'Diffgene'=diffgene))}})

Volcano_reactive <- reactive({
  if(input$volcano_cp %in% comparelist) {
    diffresult <- read.table(paste0("data/",input$volcano_cp,'_DEG.xls'),header=T,sep="\t")
    volcano <- diffresult[c("Gene_ID","log2FoldChange","pvalue","padj")]
    volcano["group"] <- "NOsignificant"
    volcano[which(volcano["padj"] <= input$volcano_q & volcano["pvalue"] <= input$volcano_p & volcano["log2FoldChange"] >= log(input$volcano_fc,2)),"group"] <- "UP"
    volcano[which(volcano["padj"] <= input$volcano_q & volcano["pvalue"] <= input$volcano_p & volcano["log2FoldChange"] <= -log(input$volcano_fc,2)),"group"] <- "DOWN"
    volcano$group <- factor(volcano$group,levels=c('UP','DOWN','NOsignificant'))
    p <-  ggplot(volcano,aes(x=log2FoldChange,y=-log10(padj),group=group,color=group)) + geom_point() +
      geom_vline(xintercept=c(-log(input$volcano_fc,2),log(input$volcano_fc,2)),linetype='dotdash',size=0.8,color='grey') +
      geom_hline(yintercept=-log10(input$volcano_q),linetype='dotdash',size=0.8,color='grey') +
      theme(panel.background=element_rect(fill="transparent"),axis.line=element_line())
    return(list('Volcano'=p))}})

Volcano_Reactive <- eventReactive(input$volcano_button,{
  if(input$volcano_cp %in% comparelist) {
    diffresult <- read.table(paste0("data/",input$volcano_cp,'_DEG.xls'),header=T,sep="\t")
    volcano <- diffresult[c("Gene_ID","log2FoldChange","pvalue","padj")]
    volcano["group"] <- "NOsignificant"
    volcano[which(volcano["padj"] <= input$volcano_q & volcano["pvalue"] <= input$volcano_p & volcano["log2FoldChange"] >= log(input$volcano_fc,2)),"group"] <- "UP"
    volcano[which(volcano["padj"] <= input$volcano_q & volcano["pvalue"] <= input$volcano_p & volcano["log2FoldChange"] <= -log(input$volcano_fc,2)),"group"] <- "DOWN"
    volcano$group <- factor(volcano$group,levels=c('UP','DOWN','NOsignificant'))
    p <-  ggplot(volcano,aes(x=log2FoldChange,y=-log10(padj),group=group,color=group)) + geom_point() +
      geom_vline(xintercept=c(-log(input$volcano_fc,2),log(input$volcano_fc,2)),linetype='dotdash',size=0.8,color='grey') +
      geom_hline(yintercept=-log10(input$volcano_q),linetype='dotdash',size=0.8,color='grey') +
      theme(panel.background=element_rect(fill="transparent"),axis.line=element_line())
    return(list('Volcano'=p))}})

Heatmap_reactive <- reactive({
  groups <- c()
  genelists <- c()
  for (i in 1:length(input$heatmap_cps)) {
    diffresult <- read.table(paste0("data/",input$heatmap_cps[i],'_DEG.xls'),header=T,sep='\t')
    diffgene <- subset(diffresult,pvalue<=as.numeric(strsplit(input$heatmap_ps,' ')[[1]][i]) & padj<=as.numeric(strsplit(input$heatmap_qs,' ')[[1]][i]) & abs(log2FoldChange)>=log(as.numeric(strsplit(input$heatmap_fcs,' ')[[1]][i]),2))
    genelist <- as.character(diffgene[,1])
    genelists <- c(genelists,genelist)
    group <- strsplit(input$heatmap_cps[i],'vs')[[1]]
    groups <- c(groups,group)}
  genelists <- genelists[!duplicated(genelists)]
  groups <- groups[!duplicated(groups)]
  groupdata <- condition[which(condition$groups1 %in% groups),]
  rownames(groupdata) <- as.character(groupdata$samples)
  fpkms <- subset(fpkm,select=as.character(groupdata$samples))
  heatmap <- fpkms[genelists,]
  heatmap <- heatmap[rowSums(heatmap)>0,]
  heatmap <- na.omit(heatmap)
  if (input$heatmap_scale=='Row'){
    heatmap_scale_value = 'row'
  }
  if(input$heatmap_scale=='Column'){
    heatmap_scale_value = 'column'
  }
  if (input$heatmap_group=='TRUE'){
    if (input$heatmap_cluster=='Both'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('TRUE'),cluster_cols=as.logical('TRUE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row,annotation_col=groupdata[,2,drop=F])}
    if (input$heatmap_cluster=='Row'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('TRUE'),cluster_cols=as.logical('FALSE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row,annotation_col=groupdata[,2,drop=F])}
    if (input$heatmap_cluster=='Column'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('FALSE'),cluster_cols=as.logical('TRUE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row,annotation_col=groupdata[,2,drop=F])}}
  if (input$heatmap_group=='FALSE'){
    if (input$heatmap_cluster=='Both'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('TRUE'),cluster_cols=as.logical('TRUE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row)}
    if (input$heatmap_cluster=='Row'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('TRUE'),cluster_cols=as.logical('FALSE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row)}
    if (input$heatmap_cluster=='Column'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('FALSE'),cluster_cols=as.logical('TRUE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row)}}
  return(list('Heatmap'=heatmap,'P'=p))})

Heatmap_Reactive <- eventReactive(input$heatmap_button,{
  groups <- c()
  genelists <- c()
  for (i in 1:length(input$heatmap_cps)) {
    diffresult <- read.table(paste0("data/",input$heatmap_cps[i],'_DEG.xls'),header=T,sep='\t')
    diffgene <- subset(diffresult,pvalue<=as.numeric(strsplit(input$heatmap_ps,' ')[[1]][i]) & padj<=as.numeric(strsplit(input$heatmap_qs,' ')[[1]][i]) & abs(log2FoldChange)>=log(as.numeric(strsplit(input$heatmap_fcs,' ')[[1]][i]),2))
    genelist <- as.character(diffgene[,1])
    genelists <- c(genelists,genelist)
    group <- strsplit(input$heatmap_cps[i],'vs')[[1]]
    groups <- c(groups,group)}
  genelists <- genelists[!duplicated(genelists)]
  groups <- groups[!duplicated(groups)]
  groupdata <- condition[which(condition$groups1 %in% groups),]
  rownames(groupdata) <- as.character(groupdata$samples)
  fpkms <- subset(fpkm,select=as.character(groupdata$samples))
  heatmap <- fpkms[genelists,]
  heatmap <- heatmap[rowSums(heatmap)>0,]
  heatmap <- na.omit(heatmap)
  if (input$heatmap_scale=='Row'){
    heatmap_scale_value = 'row'
  }
  if(input$heatmap_scale=='Column'){
    heatmap_scale_value = 'column'
  }
  if (input$heatmap_group=='TRUE'){
    if (input$heatmap_cluster=='Both'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('TRUE'),cluster_cols=as.logical('TRUE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row,annotation_col=groupdata[,2,drop=F])}
    if (input$heatmap_cluster=='Row'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('TRUE'),cluster_cols=as.logical('FALSE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row,annotation_col=groupdata[,2,drop=F])}
    if (input$heatmap_cluster=='Column'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('FALSE'),cluster_cols=as.logical('TRUE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row,annotation_col=groupdata[,2,drop=F])}}
  if (input$heatmap_group=='FALSE'){
    if (input$heatmap_cluster=='Both'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('TRUE'),cluster_cols=as.logical('TRUE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row)}
    if (input$heatmap_cluster=='Row'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('TRUE'),cluster_cols=as.logical('FALSE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row)}
    if (input$heatmap_cluster=='Column'){
      p <- pheatmap(mat=heatmap,col=colorRampPalette(rev(strsplit(input$heatmap_col,' ')[[1]]))(100),cluster_rows=as.logical('FALSE'),cluster_cols=as.logical('TRUE'),scale=heatmap_scale_value,legend=as.logical(input$heatmap_legend),show_rownames=as.logical(input$heatmap_showname),fontsize_row=input$heatmap_fontsize_row,fontsize_col=input$heatmap_fontsize_row)}}
  return(list('Heatmap'=heatmap,'P'=p))})

Venn_reactive <- reactive({
  vennlists=list()
  for (i in 1:length(input$venn_cps)) {
    diffresult <- read.table(paste0("data/",input$venn_cps[i],'_DEG.xls'),header=T,sep="\t")
    diffgene <- subset(diffresult,pvalue<=as.numeric(strsplit(input$venn_ps,' ')[[1]][i]) & padj<=as.numeric(strsplit(input$venn_qs,' ')[[1]][i]) & abs(log2FoldChange)>=log(as.numeric(strsplit(input$venn_fcs,' ')[[1]][i]),2))
    genelist <- as.character(diffgene[,1])
    vennlists[[i]] <- genelist}
  names(vennlists) <- as.character(input$venn_cps)
  venndiagram <- venn.diagram(x=vennlists,filename=NULL,scaled=F,fill=strsplit(input$venn_col_fill,' ')[[1]],cat.col=strsplit(input$venn_col_cat,' ')[[1]],cat.dist=as.numeric(strsplit(input$venn_dist_cat,' ')[[1]]),cat.cex=as.numeric(strsplit(input$venn_cex_cat,' ')[[1]]),alpha=as.numeric(strsplit(input$venn_alpha,' ')[[1]]),lty=0)
  return(list('Vennlists'=vennlists,'Venndiagram'=venndiagram))})

Venn_Reactive <- eventReactive(input$venn_button,{
  vennlists=list()
  for (i in 1:length(input$venn_cps)) {
    diffresult <- read.table(paste0("data/",input$venn_cps[i],'_DEG.xls'),header=T,sep="\t")
    print(subset(diffresult,pvalue<=0.1)[,1])
    diffgene <- subset(diffresult,pvalue<=as.numeric(strsplit(input$venn_ps,' ')[[1]][i]) & padj<=as.numeric(strsplit(input$venn_qs,' ')[[1]][i]) & abs(log2FoldChange)>=log(as.numeric(strsplit(input$venn_fcs,' ')[[1]][i]),2))
    genelist <- as.character(diffgene[,1])
    vennlists[[i]] <- genelist}
  names(vennlists) <- as.character(input$venn_cps)
  venndiagram <- venn.diagram(x=vennlists,filename=NULL,scaled=F,fill=strsplit(input$venn_col_fill,' ')[[1]],cat.col=strsplit(input$venn_col_cat,' ')[[1]],cat.dist=as.numeric(strsplit(input$venn_dist_cat,' ')[[1]]),cat.cex=as.numeric(strsplit(input$venn_cex_cat,' ')[[1]]),alpha=as.numeric(strsplit(input$venn_alpha,' ')[[1]]),lty=0,cat.pos = 0)
  return(list('Vennlists'=vennlists,'Venndiagram'=venndiagram))})

#output

output$diffgene_table <- DT::renderDataTable({
  data <- Diff_Reactive()
  datatable(data$Diffgene,rownames=FALSE,extensions=c('KeyTable','FixedColumns'),options=list(keys=T,scrollX=T))})

output$diffgene_download <- downloadHandler(
  filename='diffgene.txt',
  content = function(file) {
  data <- Diff_reactive()
  write.table(data$Diffgene,file,row.names=FALSE,sep='\t',quote=FALSE)})

output$volcano_plot <- renderPlot({
  data <- Volcano_Reactive()
  data$Volcano})

output$volcano_download <- downloadHandler(
  filename='volcano.pdf',
  content = function(file) {
  pdf(file)
  data <- Volcano_reactive()
  plot(data$Volcano)
  dev.off()})

output$heatmap_plot <- renderPlot({
  data <- Heatmap_Reactive()
  data$P})

output$heatmap_download_pdf <- downloadHandler(
  filename='heatmap.pdf',
  content = function(file) {
  pdf(file,onefile=F)
  data <- Heatmap_reactive()
  data$P
  dev.off()})

output$heatmap_download_txt <- downloadHandler(
  filename='heatmap.txt',
  content = function(file) {
  data <- Heatmap_reactive()
  write.table(data.frame(ID=rownames(data$Heatmap),data$Heatmap),file,row.names=FALSE,sep='\t',quote=FALSE)})

output$venn_plot <- renderPlot({
  data <- Venn_Reactive()
  grid.draw(data$Venndiagram)})

output$venn_download <- downloadHandler(
  filename='venn.pdf',
  content = function(file) {
  pdf(file)
  data <- Venn_reactive()
  grid.draw(data$Venndiagram)
  dev.off()})
