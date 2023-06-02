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
            menuItem("Normal", tabName="normal"),
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
        tabItem(tabName="normal",
    
            # Sidebar with a slider input for number of bins
            sidebarLayout(
                  sidebarPanel(
                      sliderInput("mean",
                                  "mean:",
                                  min = 1,
                                  max = 10,
                                  value = 5,
                                  step = 0.01),
                      sliderInput("std",
                                  "std:",
                                  min=0.1,
                                  max=5,
                                  value=1,
                                  step=0.01)
                  ),
                  mainPanel(
                      plotOutput("distPlot")
                  )
              )
        ),
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
                     plotlyOutput("histPlot")
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
                    radioButtons("topBot", "Mode:", c("top"="top",
                                                      "bot"="bottom")),
                    selectInput("attrib", "Attribute:", c('health'='hp',
                                                          'gaga'='lada'))
                  ),
                  mainPanel(
                    
                  )
                )
    )
))))
