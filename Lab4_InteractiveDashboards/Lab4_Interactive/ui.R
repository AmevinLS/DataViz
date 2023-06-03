#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(plotly)
library(shiny)
library(shinydashboard)
library(plotly)

shinyUI(dashboardPage(skin="black",
    dashboardHeader(title="Pokemon Stuff!"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Generations Histogram", tabName="genHist"),
            menuItem("DataTable", tabName="datatable"),
            menuItem("Compare types", tabName="typeComparer"),
            menuItem("Questionaire", tabName="questionaire")
        )
    ),
    dashboardBody(
    # includeCSS("www/darkly.min.css"),
    includeCSS("www/custom.css"),
    tags$style(
        HTML('
            .dataTables_wrapper {
            width: 100% !important;
            max-width: none !important;
            }
        ')  
    ),
    
    tabItems(
        tabItem(tabName="genHist",
             sidebarLayout(
                 sidebarPanel(
                     checkboxGroupInput("genPicker", "Choose generations:",
                                        c("I"="I",
                                          "II"="II",
                                          "III"="III",
                                          "IV"="IV",
                                          "V"="V",
                                          "VI"="VI",
                                          "VII"="VII",
                                          "VIII"="VIII"))
                 ),
                 mainPanel(
                     plotOutput("histPlot")
                 )
             )
        ),
        tabItem(tabName="datatable",
            fluidRow(
                box(
                    width=8,
                    height="45vh",
                    plotlyOutput("pokeScatter")
                ),
                fluidRow(
                    box(
                        width=4,
                        height="45vh",
                        title="Selected Pokemon",
                        wellPanel(
                            htmlOutput("sprite"),
                            tags$div(textOutput("pokeDescription"), 
                                     class="poke-desctiption",
                                     height="45vh")
                        )
                    )
                )
            ),
            box(
                width=12,
                title="Pokemon inside selection",
                DT::DTOutput("pokeTable")
            )
        ),
        tabItem(tabName="typeComparer",
                sidebarLayout(
                  sidebarPanel(
                    checkboxGroupInput("typePicker", "Choose types:",
                                       c("bug"="bug",
                                         "dark"="dark",
                                         "dragon"="dragon",
                                         "electric"="electric",
                                         "fairy"="fairy",
                                         "fighting"="fighting",
                                         "fire"="fire",
                                         "flying"="flying",
                                         "grass"="grass",
                                         "ghost"="ghost",
                                         "ground"="ground",
                                         "ice"="ice",
                                         "normal"="normal",
                                         "poison"="poison",
                                         "psychic"="psychic",
                                         "rock"="rock",
                                         "steel"="steel",
                                         "water"="water"))
                  ),
                  mainPanel(
                    plotlyOutput("linePlot")
                  )
              )
        ),
        tabItem(tabName="questionaire",
                sidebarLayout(
                  sidebarPanel(
                    radioButtons("topBot", "Mode:", c("top N pokemons"="top",
                                                      "bottom N pokemons"="bottom")),
                    numericInput("n", "N", value=10, min=1, max=900, step=1),
                    selectInput("attrib", "Attribute:", c('health'='hp',
                                                          'attack'='attack',
                                                          'speed'='speed',
                                                          'defense'='defense',
                                                          'speed attack'='speed attack',
                                                          'speed defense'='speed defense', 
                                                          'weight'='weight (kg)'))
                  ),
                  mainPanel(
                    style = "height: 90vh; overflow-y: auto;",
                    tableOutput('tabList')
                  )
                )
    )
))))
