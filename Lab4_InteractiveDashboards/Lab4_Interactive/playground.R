library(ggplot2)
library(tidyr)
library(dplyr)

pokedex = read.csv("data/pokemon.csv", sep="\t")

gens = c("I", "III")

chosen_poke = pokedex %>%
    filter(gen %in% gens)    

pokedex[national_number==3, "english_name"]

length(pokedex[c(), "national_number"])
pokedex[c(), "national_number"]
