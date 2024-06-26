% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/teEnrichmentCustom.R
\name{teEnrichmentCustom}
\alias{teEnrichmentCustom}
\title{Calculate tissue-specific gene enrichment using the hypergeometric test for
custom datasets}
\usage{
teEnrichmentCustom(
  inputGenes = NULL,
  tissueSpecificGenes = NULL,
  tissueSpecificGeneType = 1,
  multiHypoCorrection = TRUE,
  backgroundGenes = NULL
)
}
\arguments{
\item{inputGenes}{An GeneSet object containing the input genes.}

\item{tissueSpecificGenes}{A SummarizedExperiment object. Output from
`teGeneRetrieval` function. Default NULL.}

\item{tissueSpecificGeneType}{An integer describing the type of
tissue-specific genes to be used. 1 for 'All' (default), 2 for
'Tissue-Enriched',3 for 'Tissue-Enhanced', and 4 for 'Group-Enriched'.
Default 1.}

\item{multiHypoCorrection}{Flag to correct P-values for multiple hypothesis
using BH method. Default TRUE.}

\item{backgroundGenes}{A GeneSet object containing the background gene
list, organism type ('Homo Sapiens' or 'Mus Musculus'), and gene id
identifier (Gene Symbol or ENSEMBL identifier). The input genes must
be present in the background gene list. If not provided all the genes
will be used as background.}
}
\value{
The output is a list with three objects. The first object is the
SummarizedExperiment object containing the enrichment results, the second
object contains the tissue-specificity information of the tissue-specific
genes for genes from the input gene set, and the third is a GeneSet object
containing genes that were not identified in the tissue-specific gene data.
}
\description{
The teEnrichmentCustom function is used to calculate
tissue-specific gene enrichment using tissue-specific genes defined using
the teGeneRetrieval function.
}
\examples{
library(dplyr)
data<-system.file('extdata', 'test.expressiondata.txt', package =
'TissueEnrich')
expressionData<-read.table(data,header=TRUE,row.names=1,sep='\t')
se<-SummarizedExperiment(assays = SimpleList(as.matrix(expressionData)),
rowData = row.names(expressionData),colData = colnames(expressionData))
output<-teGeneRetrieval(se)
head(metadata(output)[['TissueSpecificGenes']])
genes<-system.file('extdata', 'inputGenesEnsembl.txt', package =
'TissueEnrich')
inputGenes<-scan(genes,character())
gs<-GeneSet(geneIds=inputGenes)
output2<-teEnrichmentCustom(gs,output)
#Plotting the P-Values
enrichmentOutput<-setNames(data.frame(assay(output2[[1]]),
row.names = rowData(output2[[1]])[,1]),
colData(output2[[1]])[,1])
enrichmentOutput$Tissue<-row.names(enrichmentOutput)
ggplot(enrichmentOutput,aes(x=reorder(Tissue,-Log10PValue),y=Log10PValue,
label = Tissue.Specific.Genes,fill = Tissue))+
geom_bar(stat = 'identity')+
labs(x='', y = '-LOG10(P-Value)')+
theme_bw()+
theme(legend.position='none')+
theme(plot.title = element_text(hjust = 0.5,size = 20),axis.title =
element_text(size=15))+
theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
panel.grid.major= element_blank(),panel.grid.minor = element_blank())
}
\author{
Ashish Jain, Geetu Tuteja
}
