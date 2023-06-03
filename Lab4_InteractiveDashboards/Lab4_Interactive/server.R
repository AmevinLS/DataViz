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
pokedex = raw_pokedex %>%
    select(national_number, gen, english_name, primary_type, secondary_type)
all_types = unique(pokedex$primary_type)

df_pokemons <- raw_pokedex %>%
  select(c('english_name', 'hp', 'attack', 'speed', 'defense', 'sp_attack', 'sp_defense', 'weight_kg')) %>%
  rename('name'='english_name', 'weight (kg)'='weight_kg', 'speed defense'='sp_defense', 'speed attack'='sp_attack')

View(df_pokemons)

df_types_stats <- raw_pokedex %>% 
  select(c('gen', 'primary_type', 'hp', 'attack', 'speed', 'defense', 'sp_attack', 'sp_defense'))

df_types_stats_2 <- raw_pokedex %>% 
  select(c('gen', 'secondary_type', 'hp', 'attack', 'speed', 'defense', 'sp_attack', 'sp_defense')) %>%
  filter(secondary_type != '') %>%
  rename(primary_type = secondary_type)

df_hist <- df_types_stats %>%
  union_all(df_types_stats_2) %>%
  select(c('gen', 'primary_type')) %>%
  rename(type=primary_type)

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

    output$histPlot = renderPlot({
        gens = input$genPicker
        chosen_poke = df_hist %>%
            filter(gen %in% gens)
        
        ggplot(chosen_poke, aes(x=type)) +
          geom_bar(fill='#00c5c7', position='dodge') +
          geom_text(stat='count',
                    aes(label=after_stat(count),
                        y=after_stat(count)+0.1),
                    hjust=-.1,
                    size=4) +
          scale_x_discrete(limits=all_types) +
          scale_y_continuous(limits=c(0,150),
                             expand=c(0, 0),
                             breaks=seq(0, 150, 25),
                             minor_breaks=seq(0, 150, 5)) +
          coord_flip() +
          labs(title="Histogram of all generations") +
          theme_bw() +
          xlab('Pokemon type') +
          ylab('count') +
          theme(plot.margin=margin(.4, .8, .4, .4, 'cm'),
                panel.grid.major.y=element_blank(),
                axis.text.x=element_text(size=15),
                axis.text.y=element_text(size=12),
                axis.title.x=element_text(size=15),
                axis.title.y=element_text(size=15),
                title=element_text(size=20))
    })
    
    output$linePlot = renderPlotly({
      types = input$typePicker
      if (length(types) == 0) {
        ggplotly()
      } else {
        chosen_types = df_types_stats %>%
          filter(primary_type %in% types)
        
        
        g <- ggplot(chosen_types, 
                    aes(x=feature, 
                        y=value, 
                        group=primary_type,
                        text=paste(feature, ": ", round(value, 2), "\n", 
                                   primary_type, sep=''))) +
          geom_point(aes(color=primary_type)) +
          geom_line(linewidth=0.1, linetype="dotted") +
          expand_limits(y=0) +
          scale_y_continuous(limits=c(0, max(chosen_types$value)+5),
                             expand=c(0, 0)) +
          labs(color="Pokemon types",
               title="Comparing mean features w.r.t. types") +
          theme_bw()
        
        ggplotly(g, tooltip="text")
      }})
    
    output$tabList = renderTable({
      sorter <- input$topBot
      attrib <- input$attrib
      
      df_subset <- df_pokemons %>%
        select(c('name', !!sym(attrib))) %>%
        arrange(!!sym(attrib))
      
      if (sorter == 'top') {
        df_subset %>% top_n(input$n) %>% arrange(desc(!!sym(attrib)))
      } else {
        df_subset %>% top_n(-input$n)
      }
    })
    
    output$pokeTable = DT::renderDataTable({
        curr_table()
    }, options=list(
        scrollX=TRUE,
        scrollY="130",
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
        scatter = ggplot(raw_pokedex, aes(x=hp, y=attack, color=factor(is_legendary))) +
            geom_jitter(width=5, height=5) +
            theme_bw()
        ggplotly(scatter, source="S")
    })
})
