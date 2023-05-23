#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
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

    # Application title
    titlePanel("Different Normal Distributions"),
    
    tabsetPanel(
        tabPanel("Normal",
    
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
        tabPanel("Generations histogram",
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
        tabPanel("DataTable",
            splitLayout(
                DT::DTOutput("pokeTable"),
                wellPanel(
                    htmlOutput("sprite"),
                    h3("Description:"),
                    tags$div(textOutput("pokeDescription"), class="wrapped")
                )
            )
        )
    )
))
