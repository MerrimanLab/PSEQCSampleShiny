library(ggvis)
library(dplyr)
poly_stats = read.table('~/eli_resquence/ggvis/poly_stats.istats',header=T)


all_values = function(x) {
 if(is.null(x)) return(NULL)
 row = poly_stats[poly_stats$ID==x$ID, ]
 paste0(names(row), ": ", format(row), collapse = "<br />")
}
poly_stats  %>% ggvis(x=~SING,key :=~ID) %>% layer_points() %>%
  add_tooltip(all_values,'hover')
