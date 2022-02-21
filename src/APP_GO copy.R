
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
imgsize <- "auto 35%"
#img <- 'http://northerntechmap.com/assets/img/loading-dog.gif'
#img <- "https://external-preview.redd.it/9TpfwjL0K9kaAphGbgdPtvlyctf6yV3yda7-NKqBU9Q.gif?format=mp4&s=cadd9bb5cb0697f40439389a2a51a87c204646c4"
#img <- 'https://i.makeagif.com/media/9-20-2017/lk3iNO.gif'
img <- "https://thumbs.gfycat.com/KeyTallAntbear-size_restricted.gif"


###############################
#####   Resume des data   #####
###############################

source(file = "src/function_Source.R")


ui <- dashboardPage(skin = "red",
                dashboardHeader(title = "SweetK"),
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
                                    titlePanel("Get Enrichment Test"),
                                    textInput(input = "geneName", label = "Enter Gene ID", value = "AT5G35390;AT2G21920;AT2G34390;AT2G45135;AT5G54070;AT1G56850;AT5G60680;AT2G44690;AT5G19040;AT5G15920;AT3G47980;AT5G06560;AT2G35070;AT3G09620;AT3G06530;AT1G18080"),
                                    pickerInput("mySubontology",label = "Pick your SubOntology", multiple = FALSE, choices = c("BP","MF","CC")),
                                    actionButton("button_action", "Launch_Test", class = "btn-success")
                                ),
                                mainPanel(
                                    DT::dataTableOutput("resultsTest")
                                )
                        )                       
                    )
                )
            
)

######  Define server  #####A
server <- function(input, output, session) {


    #############################################################
    ################        PROFIL EXPRESSION       #############
    #############################################################



    #################################################
    #############   HEATMAP PART    #################
    #################################################

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






 



}

shinyApp(ui = ui, server = server)
