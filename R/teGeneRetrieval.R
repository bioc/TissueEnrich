## To Supress Note
utils::globalVariables(c("%>%", "Gene", ".", "geneIdType",
    "SimpleList"))

#' Define tissue-specific genes by using the algorithm from the Human Protein
#' Atlas
#' @description The teGeneRetrieval function is used to define tissue-specific
#' genes, using the algorithm
#' from the HPA (Uhlén et al. 2015). It takes a gene expression
#' SummarizedExperiment object as input
#' (rows as genes and columns as tissue) and classifies the genes into
#' different gene groups. The users also have the option of changing the
#' default thresholds to vary the degree of tissue specificity of genes. More
#' details about the gene groups and HPA thresholds are provided below. More
#' details about the gene groups are provided in the vignette.
#' @author Ashish Jain, Geetu Tuteja
#' @param expressionData A SummarizedExperiment object containing gene
#' expression values.
#' @param foldChangeThreshold A numeric Threshold of fold change, default 5.
#' @param maxNumberOfTissues A numeric Maximum number of tissues in a group for
#' group enriched genes, default 7.
#' @param expressedGeneThreshold A numeric Minimum gene expression cutoff for
#' the gene to be called as expressed, default 1.
#' @export
#' @return The output is a SummarizedExperiment object containing the
#' information about the tissue-specific genes with three columns:
#' Gene, Tissue, and Enrichment group of the gene in the given tissue.
#' @examples
#' library(SummarizedExperiment)
#' data<-system.file('extdata', 'test.expressiondata.txt', package =
#' 'TissueEnrich')
#' expressionData<-read.table(data,header=TRUE,row.names=1,sep='\t')
#' se<-SummarizedExperiment(assays = SimpleList(as.matrix(expressionData)),
#' rowData = row.names(expressionData),colData = colnames(expressionData))
#' output<-teGeneRetrieval(se)
#' head(assay(output))


teGeneRetrieval <- function(expressionData, foldChangeThreshold = 5,
    maxNumberOfTissues = 7, expressedGeneThreshold = 1) {
    ### Add checks for the conditions
    # expressionData <- ensurer::ensure_that(expressionData,
    #     !is.null(.) && is(.,"SummarizedExperiment") &&
    #         !is.null(assay(.)) && (nrow(assay(.)) >
    #         0) && (ncol(assay(.)) > 1) && (ncol(rowData(.)) ==
    #         1) && (ncol(colData(.)) == 1),
    #         err_desc = "expressionData should be a
    #                     non-empty SummarizedExperiment object
    #                     with atleast 1 gene and 2 tissues.")
    # foldChangeThreshold <- ensurer::ensure_that(foldChangeThreshold,
    #     !is.null(.) && is.numeric(.) && (. >= 1),
    #         err_desc = "foldChangeThreshold should be a
    #                     numeric value greater than
    #                     or equal to 1.")
    # maxNumberOfTissues <- ensurer::ensure_that(maxNumberOfTissues,
    #                             !is.null(.) && is.numeric(.) && (. >= 2)
    #                             && (. <= ncol(expressionData)),
    #                             err_desc = "maxNumberOfTissues should be an
    #                             integer value greater than or
    #                             equal to 2 and less than the number
    #                             of tissues in the expression data.")
    # 
    # expressedGeneThreshold <- ensurer::ensure_that(expressedGeneThreshold,
    #     !is.null(.) && is.numeric(.) && (. >= 0),
    #         err_desc = "expressedGeneThreshold should be a
    #                     numeric value greater than or
    #                     equal to 0.")
    minNumberOfTissues <- 2
    # start.time <- Sys.time()
    expData <- setNames(assay(expressionData), colData(expressionData)[,1])
    geneList <- as.list(rowData(expressionData)[, 1])
    x <- lapply(seq(1, nrow(expData)), FUN = function(j) {
        df <- c()
        tpm <- expData[j, ]
        gene <- j
        tpm <- sort(tpm, decreasing = TRUE)
        highTPM <- tpm[1]

        #### Check for Not Expressed
        if (highTPM >= expressedGeneThreshold) {
            secondHighTPM <- tpm[2]
            foldChangeHigh <- highTPM/secondHighTPM
            ### Check for Tissue Enriched
            if (foldChangeHigh >= foldChangeThreshold) {
                df <- c(gene, names(tpm)[1], "Tissue-Enriched")
            } else {
                #### Check for Group Enriched
                thresholdForGroupTPM <- highTPM/foldChangeThreshold
                groupTPM <- tpm[(tpm >= thresholdForGroupTPM) &
                    (tpm >= expressedGeneThreshold), drop = FALSE]
                isFound <- FALSE
                if (length(groupTPM) <= maxNumberOfTissues &&
                    length(groupTPM) >= minNumberOfTissues) {
                        fc <- lapply(2:(length(groupTPM)),
                        FUN = function(i) {
                            meanTPMForGroup <- mean(groupTPM[seq(1, i)])
                            highestTPMOutsideGroup <- tpm[i + 1]
                            fc <- meanTPMForGroup/highestTPMOutsideGroup
                            return(fc)
                        })

                    idx <- (fc >= foldChangeThreshold)
                    if (sum(idx) > 0) {
                        index <- which.max(idx)
                        x <- lapply(seq(1, (index + 1)),
                            FUN = function(i) {
                            c(gene, names(tpm)[i], "Group-Enriched") })
                        df <- do.call("rbind", x)
                        isFound <- TRUE
                    }
                }

                if (!isFound) {
                    #### Check for Expressed In All
                    if (all(tpm >= expressedGeneThreshold)) {
                        df <- c(gene, "All", "Expressed-In-All")
                    } else {
                        #### Check for Tissue Enhanced
                        tissueEnhancedThreshold <- mean(tpm) *
                            foldChangeThreshold
                        enhancedGene <- tpm[(tpm >= tissueEnhancedThreshold) &
                            (tpm >= expressedGeneThreshold), drop = FALSE]
                        if (length(enhancedGene) >= 1) {
                            x <- lapply(names(enhancedGene),
                                FUN = function(enhancedTissue) {
                                    c(gene, enhancedTissue, "Tissue-Enhanced")
                                })
                            df <- do.call("rbind", x)
                        } else {
                            df <- c(gene, "All", "Mixed")
                        }
                    }
                }
            }
        } else {
            df <- c(gene, "All", "Not-Expressed")
        }
        return(df)
    })

    TSGenes <- do.call("rbind", x)
    colnames(TSGenes) <- c("Gene", "Tissue", "Group")
    TSGenes[, "Gene"] <- unlist(geneList[as.numeric(TSGenes[, "Gene"])])
    # end.time <- Sys.time() time.taken <- end.time -
    # start.time print(time.taken)
    return(SummarizedExperiment(assays = SimpleList(TSGenes),
        colData = colnames(TSGenes)))
}
