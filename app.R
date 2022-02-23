
#installation of needed package
if (!require("shiny")) install.packages('shiny')
if (!require("ggplot2")) install.packages('ggplot2')
if (!require("shinyWidgets")) install.packages('shinyWidgets')
if (!require("shinydashboard")) install.packages('shinydashboard')
if (!require("DT")) install.packages('DT')
if (!require("DT")) BiocManager::install("AnnotationDbi")
if (!require("topGO")) BiocManager::install("topGO")
if (!require("shinycssloaders")) install.packages('shinycssloaders')




# library 
library(shiny)
library(ggplot2)
library(shinyWidgets)
library(shinydashboard)
library(DT)
library(BiocManager)
options(repos = BiocManager::repositories())
library(topGO)
library(shinycssloaders)

imgsize <- "auto 50%"
#img <- "http://static.demilked.com/wp-content/uploads/2016/06/gif-animations-replace-loading-screen-11.gif"
img <- "http://northerntechmap.com/assets/img/loading-dog.gif"
pathToSrc <- "https://github.com/momaillard/AT_GO_Enrichment_App/raw/master/src/function_Source.R"
pathToUniverse <- "https://github.com/momaillard/AT_GO_Enrichment_App/raw/master/data/GOuniverseAT.txt" # Data produce from ATH_GO_GOSLim from TAIR (2020) with a hand made script 

source(file = pathToSrc)

ui <- dashboardPage(skin = "blue",
                dashboardHeader(title = "AtGO enrichment"),
                dashboardSidebar(
                    sidebarMenu(id = "tabs",
                        menuItem("Gene_Ontology", tabName = "Gene_ontology_Test", icon = icon("chart-line"))
                    )
                ),
                dashboardBody(
                    singleton(tags$head(HTML("
                        <script type='text/javascript'>

                        /* When recalculating starts, show loading screen */
                        $(document).on('shiny:recalculating', function(event) {
                        $('div#divLoading').addClass('show');
                        });

                        /* When new value or error comes in, hide loading screen */
                        $(document).on('shiny:value shiny:error', function(event) {
                        $('div#divLoading').removeClass('show');
                        });

                        </script>"))),

                        # CSS Code
                        singleton(tags$head(HTML(paste0("
                        <style type='text/css'>
                        #divLoading
                        {
                        display : none;
                        }
                        #divLoading.show
                        {
                        display : block;
                        position : fixed;
                        z-index: 100;
                        background-image : url('",img,"');
                        background-size:", imgsize, ";
                        background-repeat : no-repeat;
                        background-position : center;
                        left : 0;
                        bottom : 0;
                        right : 0;
                        top : 0;
                        }
                        #loadinggif.show
                        {
                        left : 50%;
                        top : 50%;
                        position : absolute;
                        z-index : 101;
                        -webkit-transform: translateY(-50%);
                        transform: translateY(-50%);
                        width: 100%;
                        margin-left : -16px;
                        margin-top : -16px;
                        }
                        div.content {
                        width : 1000px;
                        height : 1000px;
                        }
                        </style>")))),
                    tabItems(
                        tabItem(tags$body(HTML("<div id='divLoading'> </div>")),
                        tabName = "Gene_ontology_Test",
                            column(width = 6, offset =3,
                                box(width = 12,
                                    column(12, align = "center", titlePanel("Get Enrichment Results")),
                                    column(12, align = "center", textInput(input = "geneName", label = "Enter Genes ID separated by a ';'", value = "AT1G21910;AT5G56030;AT5G56010;AT5G62390;AT3G08970;AT3G24520;AT2G41690;AT1G67970;AT5G47550;AT2G38470;AT5G07350;AT2G26150;AT5G43840;AT4G19630;AT5G45710;AT5G07100;AT3G63350;AT5G62020;AT5G12140;AT2G38340;AT4G25380;AT4G18880;AT3G51910;AT1G32330;AT5G52640;AT5G61780;AT5G27660;AT5G03720;AT1G43160;AT1G77570")),
                                    column(6, align = "center", offset = 3, pickerInput("mySubontology",label = "Pick your SubOntology", multiple = FALSE, choices = c("BP","MF","CC"))),
                                    column(12, align = "center", actionButton("button_action", "Launch_Test", class = "btn-success"),
                                    downloadButton("getGO.df", "download results", class = "btn-warning"),
                                    actionButton("plot_Res", "plot The Results", class = "btn-success")
                                    )
                                )
                            ),
                                box(width = 8,
                                    DT::dataTableOutput("resultsTest")),
                                box(width = 4,
                                    plotOutput("plotTopGO",height = "750px" ))
                                )                       
                    )
                )
            
)

######  Define server  #####A
server <- function(input, output, session) {


    myClickbutton_action <- reactiveValues()

    observeEvent(input$button_action, {
        tmpvector <- strsplit(input$geneName, ";")
        tmpGeneSelect <- as.vector(tmpvector[[1]])
      
        myClickbutton_action$GeneList <- tmpGeneSelect
        myClickbutton_action$SubOnto <- input$mySubontology
        print(myClickbutton_action$SubOnto)
        print(is.character(myClickbutton_action$SubOnto))
        print(myClickbutton_action$GeneList)
    })

    getEnrichmentResults <- reactive({
        if(is.null(myClickbutton_action$GeneList)) return()
        enrichmentTest(pathToUniverse, myClickbutton_action$GeneList, myClickbutton_action$SubOnto)
    })

    output$resultsTest <- DT::renderDataTable({
        DT::datatable(getEnrichmentResults())
    })

    myClickplot_Res <- reactiveValues()

    observeEvent(input$plot_Res,{
        myClickplot_Res$resultats.df <- getEnrichmentResults()
    })


    output$plotTopGO <- renderPlot({
        if(is.null(myClickplot_Res$resultats.df)) return()
        plotGO(getEnrichmentResults())
    })

   

    output$getGO.df <- downloadHandler( 
        filename <- function () {
            paste0("GO_results",Sys.time())  
        },
        content <- function (file) {
            write.csv2(getEnrichmentResults(), file, row.names = FALSE) 
        }
    )

}

shinyApp(ui = ui, server = server)
