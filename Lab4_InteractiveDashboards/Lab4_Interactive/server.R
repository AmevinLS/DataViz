#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(dplyr)
library(tidyr)
library(imager)

raw_pokedex = read.csv("data/pokemon.csv", sep="\t")
pokedex = raw_pokedex %>%
    select(national_number, gen, english_name, primary_type, secondary_type)
all_types = unique(pokedex$primary_type)

# Define server logic
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        x = seq(0, 10, length.out=1000)
        dist_val = dnorm(x, mean=input$mean, sd=input$std)
        data = data.frame(x, dist_val)
        
        ggplot(data, aes(x=x, y=dist_val)) +
          geom_line() +
          theme_bw()

    })

    output$histPlot = renderPlot({
        gens = input$genPicker
        chosen_poke = pokedex %>%
            filter(gen %in% gens)    
        
        ggplot(chosen_poke, aes(x=primary_type)) +
            geom_bar() +
            scale_x_discrete(limits=all_types) +
            theme_bw()
    })
    
    output$pokeTable = DT::renderDataTable({
        pokedex
    }, options=list(
        scrollX=TRUE,
        scrollY="500",
        paging=FALSE,
        autowidth=TRUE
    ), selection="single"
    )
    
    output$sprite = renderUI({
        selected = input$pokeTable_rows_selected
        if (length(selected) > 0) {
            natId = pokedex[selected, "national_number"]
            url = paste0("https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/", 
                         natId, 
                         ".png")
            tags$img(src=url, width="50%", height="50%", class="center") 
        }
    })
    
    output$pokeDescription = renderText({
        selected = input$pokeTable_rows_selected
        if (length(selected) > 0) {
            raw_pokedex[selected, "description"]
        }
        else {
            "No pokemon selected!"
        }
    })
})
