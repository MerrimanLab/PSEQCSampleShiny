library(shiny)
library(ggvis)
library(dplyr)
options(AmazonS3=c('AKIAIBWPAL7F24QILCNQ'='5gaTpC5/igl27fPk/rTXotDOxnlLosr6P0dByZ78'))
s3Load("resquencingstorage/poly_stats.RData")

all_values = function(x) {
  if(is.null(x)) return(NULL)
  row = poly_stats[poly_stats$ID==x$ID, ]
  paste0(names(row), ": ", format(row), collapse = "<br />")
}
poly_stats = read.table('~/eli_resquence/ggvis/poly_stats.istats',header=T)

# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
  
  output$qc_table = renderDataTable({
    poly_stats[,input$show_vars, drop=FALSE]
  }, options = list(orderClasses = TRUE))
  
   
   poly_rct_df = reactive({
     data.frame(ID=poly_stats$ID,X=poly_stats[,names(poly_stats) == input$first_field],
                              Y=poly_stats[,names(poly_stats) == input$second_field])
})
  axis_x = reactive({
    input$first_field
  })
  axis_y = reactive({
    input$second_field
  })
 reactive({   poly_rct_df %>% ggvis(x=~X,y=~Y, key:=~ID) %>% layer_points() %>%
     add_tooltip(all_values,'hover') %>% add_axis("x",title=axis_x()) %>%
  add_axis("y", title=axis_y()) }) %>% bind_shiny("qc_plots") 
  # Create Shiny variable to allow exploration of the QC data.  
   
})
