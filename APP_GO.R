
#installation of needed package
if (!require("shiny")) install.packages('shiny')
if (!require("ggplot2")) install.packages('ggplot2')
if (!require("shinyWidgets")) install.packages('shinyWidgets')
if (!require("shinydashboard")) install.packages('shinydashboard')
if (!require("DT")) install.packages('DT')
if (!require("topGO")) BiocManager::install("topGO")
if (!require("shinycssloaders")) install.packages('shinycssloaders')
if (!require("shinyBS")) install.packages('shinyBS')



# library 
library(shiny)
library(ggplot2)
library(shinyWidgets)
library(shinydashboard)
library(DT)
library(topGO)
library(shinycssloaders)
library(shinyBS)

pathToUniverse <- "./TF_enrichment/maizeAnnotationGO_GamerV2.txt"
imgsize <- "auto 75%"
#img <- 'http://northerntechmap.com/assets/img/loading-dog.gif'
#img <- 'https://i.makeagif.com/media/9-20-2017/lk3iNO.gif'
#img <- "https://thumbs.gfycat.com/KeyTallAntbear-size_restricted.gif"
img <- "http://static.demilked.com/wp-content/uploads/2016/06/gif-animations-replace-loading-screen-11.gif"

###############################
#####   Resume des data   #####
###############################

source(file = "src/function_Source.R")


ui <- dashboardPage(skin = "blue",
                dashboardHeader(title = "Gene Ontology"),
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
                                sidebarPanel(
                                    titlePanel("Get Enrichment Results"),
                                    textInput(input = "geneName", label = "Enter Gene ID", value = "AT1G21910;AT5G56030;AT5G56010;AT5G62390;AT3G08970;AT3G24520;AT2G41690;AT1G67970;AT5G47550;AT2G38470;AT5G07350;AT2G26150;AT5G43840;AT4G19630;AT5G45710;AT5G07100;AT3G63350;AT5G62020;AT5G12140;AT2G38340;AT4G25380;AT4G18880;AT3G51910;AT1G32330;AT5G52640;AT5G61780;AT5G27660;AT5G03720;AT1G43160;AT1G77570"),
                                    pickerInput("mySubontology",label = "Pick your SubOntology", multiple = FALSE, choices = c("BP","MF","CC")),
                                    actionButton("button_action", "Launch_Test", class = "btn-success"),
                                    downloadButton("getGO.df", "download results", class = "btn-warning") 
                                ),
                                mainPanel(
                                    DT::dataTableOutput("resultsTest"),
                                    box(width = 6,
                                       plotOutput("plotTopGO",height = "750px" ))
                                )
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
        enrichmentTest("./data/GOuniverseAT.txt", myClickbutton_action$GeneList, myClickbutton_action$SubOnto)
    })

    output$resultsTest <- DT::renderDataTable({
        DT::datatable(getEnrichmentResults())
    })

    output$plotTopGO <- renderPlot({
        if(is.null(myClickbutton_action$GeneList)) return()
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
