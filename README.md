# shiny app to perform gene ontology enrichment for arbidopsis thaliana

This little shiny app perform gene enrichment test for Arabidopsis thaliana. It uses TopGO R package and associated function **[1]**. 
References data were obtained from TAIR 2020 and formatted by a hand made perl script provided in /src. 
If you don't want to download R or associated packages you can try this app is available at https://momaillard.shinyapps.io/AtGO_enrichment/

## Usage
Users just have to enter some arabidopsis genes ID (format : AT3G08970) and click on the "Launch_Test" button. 
A download button is available to download the data frame of results.
This app also perform a plotting of the results for visualization purpose.

to get more information about test perform ->  https://bioconductor.org/packages/release/bioc/vignettes/topGO/inst/doc/topGO.pdf



## bibliography

> 1. Alexa A, Rahnenfuhrer J (2021). topGO: Enrichment Analysis for Gene Ontology. R package version 2.46.0.

