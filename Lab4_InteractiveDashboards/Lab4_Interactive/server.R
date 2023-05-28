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
library(plotly)
library(scales)

raw_pokedex = read.csv("data/pokemon.csv", sep="\t")
raw_pokedex = raw_pokedex %>%
    mutate(is_legendary=if_else(is_legendary==1, "Yes", "No"),
           is_mythical=if_else(is_mythical==1, "Yes", "No"),
           is_sublegendary=if_else(is_sublegendary==1, "Yes", "No"))
scatter_pokedex = raw_pokedex %>%
    select(everything())
pokedex = raw_pokedex %>%
    select(national_number, gen, english_name, primary_type, secondary_type)
all_types = unique(pokedex$primary_type)

df_types_stats <- raw_pokedex %>% 
  select(c('primary_type', 'hp', 'attack', 'speed', 'defense', 'sp_attack', 'sp_defense'))

df_types_stats_2 <- raw_pokedex %>% 
  select(c('secondary_type', 'hp', 'attack', 'speed', 'defense', 'sp_attack', 'sp_defense')) %>%
  filter(secondary_type != '') %>%
  rename(primary_type = secondary_type)

df_types_stats <- df_types_stats %>%
  union_all(df_types_stats_2) %>%
  group_by(primary_type) %>%
  summarise_at(c('hp', 'attack', 'speed', 'defense', 'sp_attack', 'sp_defense'), mean, na.rm=T) %>%
  pivot_longer(cols=c('hp', 'attack', 'speed', 'defense', 'sp_attack', 'sp_defense'),
               names_to='feature',
               values_to='value')

# Define server logic
shinyServer(function(input, output) {
    
    curr_table = reactive({
        selected = event_data(event="plotly_selected", source="S", priority="event")
        if(!is.null(selected)) {
            selected_data = raw_pokedex[selected$pointNumber, ]
            res = pokedex %>%
                filter(national_number %in% selected_data$national_number)
        } else {
            res = NULL
        }
        
        res
    })
    
    selected_natId = reactive({
        curr_table()[input$pokeTable_rows_selected, "national_number"]
    })
    
    
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
    
    output$linePlot = renderPlotly({
      types = input$typePicker
      chosen_types = df_types_stats %>%
        filter(primary_type %in% types)
      
      ggplotly(ggplot(chosen_types, aes(x=feature, y=value, group=primary_type)) +
        geom_point() +
        geom_line() +
        expand_limits(y=0) +
        labs(title="Comparing types w.r.t. their mean features") +
        theme_bw()
    )})

    output$pokeTable = DT::renderDataTable({
        curr_table()
    }, options=list(
        scrollX=TRUE,
        scrollY="150",
        paging=FALSE,
        autowidth=TRUE
    ), selection="single"
    )
    
    output$sprite = renderUI({
        natId = selected_natId()
        if (length(natId) > 0) {
            url = paste0("https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/", 
                         natId, 
                         ".png")
            tags$img(src=url, width="50%", height="50%", class="center") 
        }
    })
    
    output$pokeDescription = renderText({
        natId = selected_natId()
        if (length(natId) > 0) {
            raw_pokedex[raw_pokedex$national_number==natId, "description"]
        }
        else {
            "No pokemon selected!"
        }
    })
    
    output$pokeScatter = renderPlotly({
        scatter = ggplot(scatter_pokedex, aes_string(x=input$x_axis, y=input$y_axis, color=input$hue)) +
            geom_jitter(width=5, height=5) +
            theme_bw()
        scatter = ggplotly(scatter, source="S")
        scatter
    })
})
