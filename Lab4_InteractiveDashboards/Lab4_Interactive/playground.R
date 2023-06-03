library(ggplot2)
library(tidyr)
library(dplyr)
suppressPackageStartupMessages(library(circlize))

pokedex = read.csv("data/pokemon.csv", sep="\t")

df_pokemons <- raw_pokedex %>%
  select(c('english_name', 'hp', 'attack', 'speed', 'defense', 'sp_attack', 'sp_defense', 'weight_kg'))

df_subset <- df_pokemons %>%
  select(c('english_name', 'attack')) %>%
  top_n(10, 'attack') %>%
  arrange(!!sym('attack'))

View(df_subset)

df_types_only <- pokedex %>%
  select('primary_type', 'secondary_type') %>%
  filter(secondary_type != '')

df_types = read.csv('data/types_colors.csv')

all_types = df_types$type

N = length(all_types)

m1 = matrix(0, N, N)

rownames(m1) = all_types
colnames(m1) = all_types

for (row in 1:nrow(df_types_only)) {
  word = df_types_only[row, 'primary_type']
  i_1 = which(all_types == word)
  word = df_types_only[row, 'secondary_type']
  i_2 = which(all_types==word)
  # print(paste(i_1, i_2))
  m1[i_1, i_2] = m1[i_1, i_2] + 1
}

set.seed(1000)

View(df_types_only)

chordDiagram(df_types_only)
