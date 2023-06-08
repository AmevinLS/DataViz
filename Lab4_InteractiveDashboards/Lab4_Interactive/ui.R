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

scatterplot_height = "59vh"
x_choices = c("hp", "attack", "defense", "sp_attack", "sp_defense", "speed")
y_choices = x_choices
hue_choices = c("is_legendary", "is_sublegendary", "is_mythical", "gen")
x_selected = "hp"
y_selected = "attack"
hue_selected = "is_legendary"

shinyUI(dashboardPage(skin="black",
    dashboardHeader(title=span("Pokemon Stuff!", style="font-family: RowdyLight, sans-serif;")),
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
            menuItem("Compare types", tabName="typeComparer"),
            menuItem("Build Your Team", tabName="teamBuilder"),
            menuItem("Questionaire", tabName="questionaire")
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
                    title="Pokemon scatterplot",
                    height=scatterplot_height,
                    plotlyOutput("pokeScatter")
                ),
                fluidRow(
                    box(
                        width=4,
                        background="navy",
                        height=scatterplot_height,
                        title="Selected Pokemon (from table)",
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
                title="Pokemon inside selection (use Box-select or Lasso-select in scatter)",
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
        tabItem(tabName="teamBuilder",
            fluidPage(
                column(
                    width=4,
                    box(
                        title="Available Pokemon",
                        width=12,
                        DT::DTOutput("pokePickerTable"),
                        actionButton("addToTeamButton", "Add to Team"),
                    )
                ),
                column(
                    width=4,
                    box(
                        title="Current Team (max 6 members)",
                        width=12,
                        DT::DTOutput("pokeTeamTable"),
                        actionButton("removeFromTeamButton", "Remove from Team")
                    )
                ),
                column(
                    width=4,
                    box(
                        title="Pokemon type distribution",
                        width=12,
                        plotlyOutput("teamTypePiechart")
                    )
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
