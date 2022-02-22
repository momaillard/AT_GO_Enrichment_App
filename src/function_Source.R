
enrichmentTest <- function (universeFile, interestingGenes, subOntology){
  geneID2GO <- readMappings(file = universeFile)
  print("OK1")
  geneUniverse <- names(geneID2GO)
  geneList <-  factor(as.integer(geneUniverse %in% interestingGenes))
  print(paste0("nombre de genes dans ref = ", length(which(geneUniverse %in% interestingGenes)) ))
  print(paste0("ma subonto est", subOntology))
  names(geneList) <- geneUniverse
  myGOdata <- new("topGOdata", ontology = subOntology, allGenes = geneList,  annot = annFUN.gene2GO, gene2GO = geneID2GO)
  
  # run the Fisher's exact tests
  resultClassic <- runTest(myGOdata, algorithm = "classic", statistic = "fisher")
  resultElim <- runTest(myGOdata, algorithm = "elim", statistic = "fisher")
  resultTopgo <- runTest(myGOdata, algorithm = "weight01", statistic = "fisher")


  
  # see how many results we get where weight01 gives a P-value <= 0.001:
  mysummary <- summary(attributes(resultElim)$score <= 0.01) # how many terms is it true that P <= 0.001
  #print(paste0("attributes ", attributes(resultElim)$score <= 0.01))
  print(paste0("mySummary ", mysummary))
  print(paste0("valeur de summary 0.01 = ",mysummary))
  print(resultElim)
  if (length(mysummary) == 3 & as.numeric(mysummary[3]) > 30 ){ # Test si il y a des GO significatifs + bug quand un seul GO est significatif ? d'où cette deuxieme condition ###
    print(paste0("mysummary [3] = ", mysummary[3]))
    numsignif <- as.integer(mysummary[[3]])
  }
  else {
    numsignif <- 50 # si pas de GO significatifs alors on print les 50 premiers termes
  }
  print(paste0(numsignif, " termes conservés"))
  
  allRes <- GenTable(myGOdata, classicFisher = resultClassic, elimFisher = resultElim, topgoFisher = resultTopgo,
                     orderBy = "elimFisher", ranksOf = "classicFisher", topNodes = numsignif)

  NUMERIC_COL <- c("classicFisher", "topgoFisher", "elimFisher")
  
  for( el in NUMERIC_COL){
    allRes[,el] <- as.numeric(allRes[,el])
  }
  
  print("Fin calucl Enrichissement")
  findDeScript <- TRUE
  # List2Return <- list(allRes, myGOdata, resultClassic, findDeScript) 
  return(allRes)
  
}

plotGO <- function (matrix){
        allGO <- matrix
        allGO$Gene_number <- as.numeric(allGO$Significant)
        allGO$elimFisher <- as.numeric(as.character(allGO$elimFisher))
        allGO$log10_elimFish <- -(log10(allGO$elimFisher))
        GO_sub <- allGO[order(allGO$log10_elimFish, decreasing = TRUE),]
        GO_sub <- GO_sub[1:30,]
        myPlot <- ggplot(GO_sub) +
        geom_point(data = GO_sub, aes(x = Term, y = log10_elimFish, size = Gene_number, colour = log10_elimFish), alpha =.7)+
        scale_x_discrete(limits = GO_sub$Term)+
        scale_color_gradient(low ="green", high="red", limits=c(0, NA))+
        coord_flip()+
        theme_bw()+
        ggtitle("GO enrichment plot") +
        theme(axis.ticks.length=unit(-0.1, "cm"),
                axis.text.x = element_text(margin = margin(5,5,0,5,"pt")),
                axis.text.y = element_text(margin = margin(5,5,5,5,"pt")),
                axis.text = element_text(color = "black"),
                panel.grid.minor = element_blank(),
                legend.title.align=0.5)+
        #geom_hline(yintercept = 3, linetype = "dashed", color = "azure4", size = 0.35)+
        xlab("GO terms")+
        ylab("log10_pval")+
        labs(color = "log10_pval", size = "Number of genes")
        return(myPlot)
}
