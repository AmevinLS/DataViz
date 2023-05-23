library(ggplot2)
library(tidyr)
library(dplyr)

pokedex = read.csv("data/pokemon.csv", sep="\t")

gens = c("I", "III")

chosen_poke = pokedex %>%
    filter(gen %in% gens)    
