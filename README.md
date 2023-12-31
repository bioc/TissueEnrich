# TissueEnrich: R package to carry out tissue-specific gene enrichment.

**Requirement**

You need R version above 3.5 to run this application. Other dependencies are:

* `dplyr (>= 0.7.3)`
* `ensurer (>= 1.1)`
* `ggplot2 (>= 2.2.1)`
* `tidyr (>=0.8.0)`
* `SummarizedExperiment (>= 1.6.5)`
* `GSEABase (>= 1.38.2)`

**How to install the R package**

* Download or fork the bitbucket repository
* Open R terminal or RStudio terminal
* Install Dependencies
* `install.packages(c("dplyr","ensurer","ggplot2","tidyr"))`
* `install.packages("BiocManager")`
* `BiocManager::install("SummarizedExperiment")`
* `BiocManager::install("GSEABase")`
* Now install the `devtools` package.
* `install.packages(devtools)`
* `library(devtools)`
* Run command `install_github("Tuteja-Lab/TissueEnrich")`

**More about the package**

* Check more details about the package in the vignette `vignette("TissueEnrich")`
