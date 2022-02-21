library(topGO)
library(ggplot2)

source("/home/maillard/Documents/KPH/tmp/pourMatti/data/functionGOToSource.R")


upList <- #your vector 
resultsGO <- enrichmentFromSRPEG("/home/maillard/Documents/KPH/tmp/pourMatti/data/GOuniverseAT.txt", VectorTest, "BP") #launch analysis 

allGO <- resultsGO[[1]]
allGO$Gene_number <- as.numeric(allGO$Significant)
allGO$elimFisher <- as.numeric(as.character(allGO$elimFisher))
allGO$log10_elimFish <- -(log10(allGO$elimFisher))
GO_sub <- allGO[order(allGO$log10_elimFish, decreasing = TRUE),]

####
GO_sub <- GO_sub[c(2:40),]
#ggplot 

ggplot(GO_sub) +
  #geom_hline(yintercept = 1, linetype="dashed", 
  #           color = "azure4", size=.5)+
  geom_point(data=GO_sub, aes(x = Term, y = log10_elimFish, size = Gene_number, colour = log10_elimFish), alpha=.7)+
  scale_x_discrete(limits = GO_sub$Term)+
  scale_color_gradient(low ="green", high="red", limits=c(0, NA))+
  coord_flip()+
  theme_bw()+
  ggtitle("youtTitle") +
  theme(axis.ticks.length=unit(-0.1, "cm"),
        axis.text.x = element_text(margin=margin(5,5,0,5,"pt")),
        axis.text.y = element_text(margin=margin(5,5,5,5,"pt")),
        axis.text = element_text(color = "black"),
        panel.grid.minor = element_blank(),
        legend.title.align=0.5)+
  #geom_hline(yintercept = 3, linetype = "dashed", color = "azure4", size = 0.35)+
  xlab("GO biological processes")+
  ylab("-log10_pval")+
  labs(color="log10_pval", size = "Number of genes")
