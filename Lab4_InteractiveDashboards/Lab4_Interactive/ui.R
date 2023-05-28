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

scatterplot_height = "55vh"
x_choices = c("hp", "attack", "defense", "sp_attack", "sp_defense", "speed")
y_choices = x_choices
hue_choices = c("is_legendary", "is_sublegendary", "is_mythical", "gen")
x_selected = "hp"
y_selected = "attack"
hue_selected = "is_legendary"

shinyUI(dashboardPage(skin="black",
    dashboardHeader(title="Pokemon Stuff!"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Generations Histogram", tabName="genHist"),
            menuItem("Pokemon picker", tabName="pokemon_picker",
                     menuItem("Datatable", tabName="datatable"),
                     menuItem("Paremeters", tabName="parameters",
                              selectInput("x_axis", "X Axis", 
                                          choice=x_choices,
                                          selected=x_selected),
                              selectInput("y_axis", "Y Axis",
                                          choice=y_choices,
                                          selected=y_selected),
                              selectInput("hue", "Hue",
                                          choice=hue_choices,
                                          selected=hue_selected)
                    )
            ),
            menuItem("Compare types", tabName="typeComparer")
        )
    ),
    dashboardBody(class="custom-dashboard-body",
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
                     checkboxGroupInput("genPicker", "Generations:",
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
                    height=scatterplot_height,
                    plotlyOutput("pokeScatter")
                ),
                fluidRow(
                    box(
                        width=4,
                        background="navy",
                        height=scatterplot_height,
                        title="Selected Pokemon",
                        wellPanel(
                            class="poke-well-panel",
                            tags$div(class="poke-name", textOutput("pokeName")),
                            htmlOutput("sprite"),
                            textOutput("pokeDescription")
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
                                       c("grass"="grass",
                                         "fire"="fire",
                                         "water"="water",
                                         "bug"="bug",
                                         "normal"="normal",
                                         "poison"="poison",
                                         "electric"="electric",
                                         "ground"="ground",
                                         "fairy"="fairy",
                                         "fighting"="fighting",
                                         "psychic"="psychic",
                                         "rock"="rock",
                                         "ghost"="ghost",
                                         "ice"="ice",
                                         "dragon"="dragon",
                                         "dark"="dark",
                                         "steel"="steel",
                                         "flying"="flying"))
                  ),
                  mainPanel(
                    plotlyOutput("linePlot")
                  )
              )
        )
    )
)))
