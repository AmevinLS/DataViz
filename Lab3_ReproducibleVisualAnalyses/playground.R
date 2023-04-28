library(tidyr)
library(dplyr)
library(ggplot2)

#=================

invents = read.csv("rebrickable/inventories.csv.gz")

invent_sets = read.csv("rebrickable/inventory_sets.csv.gz")
sets = read.csv("rebrickable/sets.csv.gz")
themes = read.csv("rebrickable/themes.csv.gz")

invent_minifigs = read.csv("rebrickable/inventory_minifigs.csv.gz")
minifigs = read.csv("rebrickable/minifigs.csv.gz")

invent_parts = read.csv("rebrickable/inventory_parts.csv.gz")
parts = read.csv("rebrickable/parts.csv.gz")
colors = read.csv("rebrickable/colors.csv.gz")
elements = read.csv("rebrickable/elements.csv.gz")
part_categs = read.csv("rebrickable/part_categories.csv.gz")
part_rels = read.csv("rebrickable/part_relationships.csv.gz")

# Scatterplot of total_quant x num_parts of sets
#================

ggplot(sets, aes(x=num_parts)) +
  geom_histogram() +
  theme_bw()


fig_num_quantities = invent_minifigs %>%
  group_by(fig_num) %>%
  summarize(total_quant=sum(quantity))

fig_quant_to_parts = fig_num_quantities %>%
  inner_join(minifigs, by="fig_num")
  
ggplot(fig_quant_to_parts, aes(x=total_quant, y=num_parts)) +
  geom_jitter(position=position_jitter(width=0.5, height=0.5), alpha=0.5) +
  scale_x_sqrt() + 
  scale_y_sqrt() +
  theme_bw()

# GOOD, Barplot of number of new sets per year
#================

years_set_amnts = sets %>%
  group_by(year) %>%
  summarize(n=n(), med_num_parts=median(num_parts))

years_set_amnts$num_parts_cat = 
  cut(years_set_amnts$med_num_parts, breaks=c(0, 20, 40, 60, 80, 100, +Inf))

ggplot(years_set_amnts, aes(x=year, y=n, fill=factor(num_parts_cat))) +
  geom_bar(stat="identity", color="#000000") +
  scale_fill_brewer(palette="YlGnBu") + 
  stat_smooth(formula=y~x, fill=NA, alpha=0.3, size=1.3) +
  scale_y_continuous(limits=c(0, 1250), expand=c(0,0)) +
  labs(fill="Median number \nof parts in set",
       title="Number of new sets by year",
       y="Number of sets") + 
  theme_bw() +
  theme(plot.title=element_text(hjust=0.5))

#================

set_parts_quant = sets %>%
  inner_join(invent_sets, by="set_num") %>%
  group_by(set_num) %>%
  summarize(parts=sum(num_parts), tot_quant=sum(quantity))

# POSSIBLY GOOD. Barplot of quantities categories of parts
#================

categs_counts = invent_parts %>%
  inner_join(parts, by="part_num") %>%
  group_by(part_cat_id) %>%
  summarize(tot_quant=sum(quantity)) %>%
  inner_join(part_categs, by=join_by(part_cat_id == id)) %>%
  arrange(desc(tot_quant)) %>%
  top_n(15, tot_quant)

ggplot(categs_counts, aes(x=factor(name, level=rev(name)), y=tot_quant)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_bw()

# POSSIBLY GOOD. Barplot of quantities of each color (with color of bar = color)
#================

color_quants = invent_parts %>%
  group_by(color_id) %>%
  summarize(tot_quant=sum(quantity)) %>%
  inner_join(colors, by=join_by(color_id == id)) %>%
  top_n(15, tot_quant)

color_quants$rgb = paste("#", color_quants$rgb, sep="")

ggplot(color_quants, aes(x=factor(name), y=tot_quant)) +
  geom_bar(stat="identity",
           fill=color_quants$rgb,
           color="#000000") +
  coord_flip() +
  theme_bw()

# Heatmap stuff
#================

ggplot(sets, aes(x=year, y=theme_id, fill=num_parts)) +
  geom_tile()

x = seq(1, 10)
y = seq(1, 10)
temp_data = expand.grid(X=x, Y=y)
temp_data$Z = runif(100, 0, 5)
ggplot(temp_data, aes(x=X, y=Y, fill=Z)) +
  geom_tile()

# Number of available colors for each category
#================

categ_color_cnts = invent_parts %>%
  inner_join(parts, by="part_num") %>%
  group_by(part_cat_id) %>%
  summarize(color_cnt=n_distinct(color_id)) %>%
  inner_join(part_categs, by=join_by(part_cat_id == id)) %>%
  arrange(color_cnt)

ggplot(categ_color_cnts, aes(x=factor(name, levels=name), y=color_cnt)) +
  geom_bar(stat="identity") +
  coord_flip() +
  theme_bw()


# Scatter plot with all colors and their counts
#================

strtoi(c("12", "34", "56"))

colorsum = function(rgb_colors) {
  res = rep(0, length(rgb_colors))
  i = 1
  for (rgb_color in rgb_colors) {
    r = substring(rgb_color, 1, 2)
    g = substring(rgb_color, 3, 4)
    b = substring(rgb_color, 5, 6)
    res[i] = sum(strtoi(c(r,g,b), base=16))
    i = i + 1
  }
  return(res)
}

colorsum(c("000001", "000010", "000100"))

color_cnts = invent_parts %>%
  group_by(color_id) %>%
  summarize(color_cnt=sum(quantity)) %>%
  inner_join(colors, by=join_by(color_id == id)) %>%
  filter(color_id != 9999) %>%
  mutate(rgb_int = colorsum(rgb))

color_cnts$rgb = paste("#", color_cnts$rgb, sep="")

ggplot(color_cnts, aes(x=rgb, y=color_cnt)) +
  geom_point(color=color_cnts$rgb, size=3) +
  scale_y_log10() +
  theme_bw()
