library(ggplot2)
library(tidyr)
library(dplyr)

pokedex = read.csv("data/pokemon.csv", sep="\t")

df_pokemons <- raw_pokedex %>%
  select(c('english_name', 'hp', 'attack', 'speed', 'defense', 'sp_attack', 'sp_defense', 'weight_kg'))

df_subset <- df_pokemons %>%
  select(c('english_name', 'attack')) %>%
  top_n(10, 'attack') %>%
  arrange(!!sym('attack'))

View(df_subset)
