library(tidyr)
library(dplyr)
library(ggplot2)
library(plotly)

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
  geom_jitter(position=position_jitter(width=0.5, height=0.5), 
              alpha=0.1, 
              color="#1d91c0") +
  geom_rect(aes(xmin=0.32, xmax=3.2, ymin=1.3, ymax=13),
            color="#0c2c84",
            alpha=0,
            size=1) +
  scale_x_log10(n.breaks=10) + 
  scale_y_log10(n.breaks=10) +
  labs(title="Sets according to their quantity and parts",
       x="Total quantity of set",
       y="Number of parts in set") +
  theme_bw() +
  theme(plot.title=element_text(hjust=0.5))

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

get_root_ids = function(theme_ids) {
  root_ids = rep(0, length(theme_ids))
  i = 1
  for (theme_id in theme_ids) {
    curr_id = theme_id
    parent_id = themes %>%
      filter(id == curr_id) %>%
      .[1, "parent_id"]
    while (!is.na(parent_id)) {
      curr_id = parent_id
      parent_id = themes %>%
        filter(id == curr_id) %>%
        .[1, "parent_id"]
    }
    root_ids[i] = curr_id
    i = i + 1
  }
  return(root_ids)
}

themes_mod = themes %>%
  mutate(root_id=get_root_ids(id))

themes_years = sets %>%
  inner_join(themes_mod, by=join_by(theme_id == id)) %>%
  group_by(year, root_id) %>%
  summarize(count=n()) %>%
  inner_join(themes, by=join_by(root_id == id))

ggplot(themes_years, aes(x=year, y=name, fill=count)) +
  geom_tile()

# GOOD. Number of available colors for each category
#================

categ_color_cnts = invent_parts %>%
  inner_join(parts, by="part_num") %>%
  group_by(part_cat_id) %>%
  summarize(color_cnt=n_distinct(color_id)) %>%
  inner_join(part_categs, by=join_by(part_cat_id == id)) %>%
  arrange(color_cnt)

splitcat = rep("middle", nrow(categ_color_cnts))
n_best = 10
splitcat[1:n_best] = rep(paste("Worst", n_best), n_best)
splitcat[(66-n_best+1):66] = rep(paste("Best", n_best), n_best)
categ_color_cnts$splitcat = splitcat
categ_color_cnts = categ_color_cnts %>%
  filter(splitcat != "middle")

bar_colors = rep(c("#225ea8", "#41b6c4"), length.out=nrow(categ_color_cnts))

p = ggplot(categ_color_cnts, aes(x=factor(name, levels=name), y=color_cnt)) +
  geom_bar(stat="identity", fill=bar_colors) +
  coord_flip() +
  scale_y_continuous(limits=c(0, 120), expand=c(0, 0)) +
  facet_grid(splitcat ~ ., scales="free") +
  labs(y="Number of available colors",
       x="Category",
       title="Available colors for each category") +
  theme_minimal()

p

ggplotly(p)

# POSSIBLY GOOD. Scatter plot with all colors and their counts
#================

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


#================

invent_parts_col = invent_parts %>%
  inner_join(colors, by=join_by(color_id == id)) %>%
  mutate(color_sum=colorsum(rgb))

ggplot(invent_parts_col, aes(x=color_sum)) +
  geom_histogram(bins=20)


ggplot(sets, aes(x=num_parts)) +
  geom_histogram() +
  scale_y_sqrt() +
  theme_bw()

#================

themes_first_years = sets %>%
  group_by(theme_id) %>%
  summarize(first_year=min(year))

themes_quants = invent_sets %>%
  inner_join(sets, by="set_num") %>%
  group_by(theme_id) %>%
  summarize(tot_quant=sum(quantity)) %>%
  top_n(10, tot_quant)

theme_avg_parts = sets %>%
  group_by(theme_id) %>%
  summarize(avg_parts=mean(num_parts))

thm_quants_fyears = themes_first_years %>%
  inner_join(themes_quants, by="theme_id") %>%
  inner_join(theme_avg_parts, by="theme_id") %>%
  inner_join(themes, by=join_by(theme_id == id)) %>%
  arrange(desc(avg_parts))

colors = c("#081d58", "#253494", "#225ea8", "#1d91c0", "#41b6c4",
           "#7fcdbb", "#c7e9b4", "#edf8b1", "#ffffd9", "#ffffff")
vjusts = c(3.6, 4, 3.3, 3, 3, 2, -2.5, 1.7, 1, -2)
hjusts= c(-0.2, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5)
ggplot(thm_quants_fyears, aes(x=first_year, y=tot_quant,label=name)) +
  geom_point(aes(size=avg_parts), fill=colors, color="black", shape=21, alpha=0.7) +
  scale_size(name="Size", range=c(5, 35)) +
  geom_point(size=1.5, color="black") +
  geom_text(size=4, color="black", hjust=hjusts, vjust=-vjusts) +
  scale_x_continuous(limits=c(1980, 2025)) +
  scale_y_continuous(expand=c(0.1, 0.1)) +
  theme_minimal() +
  theme(legend.position="none", plot.title=element_text(size=18, hjust=0.5)) +
  labs(x="Year of First Introduction",
       y="Total Quantity in Inventories",
       title="Top 10 Themes of Sets",
       subtitle="(size indicates average number of parts in set)")
  