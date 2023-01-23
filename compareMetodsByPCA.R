library('edgeR')
library('factoextra')
library('cowplot')

# Use counts from whole genes not just exons
geneCountsBarraCUDA <- read.table("./featurecounts/barraCUDA/geneTable.csv", header = TRUE, sep = "\t", row.names = 1, check.names = FALSE)
geneCountsSTAR <- read.table("./featurecounts/STAR/geneTable.csv", header = TRUE, sep = "\t", row.names = 1, check.names = FALSE)
sampleNames<-colnames(geneCountsBarraCUDA)
geneNames<-rownames(geneCountsBarraCUDA )

# Check if tables are organized in the same way
# Yes
all(sampleNames == colnames(geneCountsSTAR))
all(geneNames == rownames(geneCountsSTAR ))

# Set up indexing of samples
splitted<-strsplit(sampleNames, "-")
sampleByReplicate<-matrix(unlist(splitted), ncol=5, byrow=TRUE)[,5]
sampleByTime<-matrix(unlist(splitted), ncol=5, byrow=TRUE)[,4]
sampleByCondition<-matrix(unlist(splitted), ncol=5, byrow=TRUE)[,3]
sampleByGenotype<-matrix(unlist(splitted), ncol=5, byrow=TRUE)[,2]
sampleBySample<-matrix(unlist(splitted), ncol=5, byrow=TRUE)[,1]

# Remove low expressed genes < mean 10
highBarraCUDA <- apply(as.matrix(geneCountsBarraCUDA), 1, mean) > 10
highSTAR <- apply(as.matrix(geneCountsSTAR), 1, mean) > 10
highBoth <- highBarraCUDA & highSTAR
geneCountsBarraCUDA <- geneCountsBarraCUDA[highBoth,]
geneCountsSTAR <- geneCountsSTAR[highBoth,]

# Normalize counts CPM
DGEGeneCounts<-DGEList(counts = geneCountsBarraCUDA)
DGEGeneCounts <- calcNormFactors(DGEGeneCounts) # TMM normalization
BarraCUDA_CPM<-cpm(DGEGeneCounts[,])

DGEGeneCounts<-DGEList(counts = geneCountsSTAR)
DGEGeneCounts <- calcNormFactors(DGEGeneCounts) # TMM normalization
STAR_CPM<-cpm(DGEGeneCounts[,])

# Do PCAs
barraCUDApca<-prcomp(t(BarraCUDA_CPM))
STARpca<-prcomp(t(STAR_CPM))
sampleByCondition30C0h<-sampleByCondition
sampleByCondition30C0h[sampleByTime=="0h"]<-"30C"

A <- fviz_pca_ind(barraCUDApca, label="none", repel = FALSE, habillage = sampleByGenotype ) + labs(title="barraCUDA by genotypes") + theme(legend.position = "none")
B <- fviz_pca_ind(STARpca, label="none", repel = FALSE, habillage = sampleByGenotype ) + labs(title="STAR by genotypes") + theme(legend.position = "none")
C <- fviz_pca_ind(barraCUDApca, label="none", repel = FALSE, habillage = sampleByCondition30C0h ) + labs(title="barraCUDA by conditions") + theme(legend.position = "none")
D <- fviz_pca_ind(STARpca, label="none", repel = FALSE, habillage = sampleByCondition30C0h ) + labs(title="STAR by conditions") + theme(legend.position = "none")
plot_grid(A,B,C,D, ncol = 2)
ggsave("PCAcomparison.png", bg = "white")
