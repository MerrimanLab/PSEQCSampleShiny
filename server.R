library(shiny)
library(ggvis)
library(dplyr)
#options(AmazonS3=c('AKIAIBWPAL7F24QILCNQ'='5gaTpC5/igl27fPk/rTXotDOxnlLosr6P0dByZ78'))
#s3Load("resquencingstorage/poly_stats.RData")
mds=read.table("plink.mds",header=T)
phenotypes=read.table("phenotypes_filter.txt",header=T)
urate=read.table("pheno_euro.txt",header=F)
colnames(urate) = c("name","hyper")

all_values = function(x) {
  if(is.null(x)) return(NULL)
  row = poly_stats[poly_stats$ID==x$ID, ]
  paste0(names(row), ": ", format(row), collapse = "<br />")
}
remove_values = function(x){
  if(is.null(x)) return(NULL)
 # paste0(length(all_sample))
 # print(x$ID)
 ## print(all_sample)
  #print(which(x$ID == all_sample))
  index = which(x$ID == poly_stats$ID)
  remove_index = which(index == all_sample)
  #print(remove_index)
 # paste0("Are you sure you want to remove: ",x$ID)
#  tabl()
  if (length(remove_index) != 0){
  #  print("remove")
   # print(remove_index)
    all_sample <<- all_sample[-remove_index]
  }
  
  paste0((x$ID))
  
  
}
poly_stats = read.table('all.istats',header=T)
all_sample <<- 1:length(poly_stats$ID)


# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
  observe ({
    input$reset_samples
    all_sample <<- 1:length(poly_stats$ID)  
    print(length(all_sample))
  })
  
  output$qc_table = renderDataTable({
    poly_stats[,input$show_vars, drop=FALSE]
  }, options = list(orderClasses = TRUE))
   
   poly_rct_df = reactive({
     samp=all_sample
   #  print(samp)
      input$refresh_samples
      input$reset_samples
     data.frame(ID=poly_stats$ID[samp],X=poly_stats[samp ,names(poly_stats) == input$first_field],
                              Y=poly_stats[samp ,names(poly_stats) == input$second_field])
})
  axis_x = reactive({
    input$first_field
  })
  axis_y = reactive({
    input$second_field
  })
 reactive({   poly_rct_df %>% ggvis(x=~X,y=~Y, key:=~ID) %>% layer_points() %>%
     add_tooltip(all_values,'hover') %>% add_tooltip(remove_values,"click") %>% add_axis("x",title=axis_x()) %>%
  add_axis("y", title=axis_y()) }) %>% bind_shiny("qc_plots") 
  # Create Shiny variable to allow exploration of the QC data.  
   output$download_s <- downloadHandler(
      filename = "samples.txt",
      content = function(file) {
        write.table(poly_stats$ID[all_sample], file,row.names=F, col.names=F) 
      } 
    )

  reactive_summary = reactive ({
    samp = all_sample
    input$first_field
    input$second_field
    input$refresh_samples
    input$reset_samples
    summary(poly_stats[samp,2:ncol(poly_stats)])
  })
  output$indiv_table <- renderTable(reactive_summary())
   # QC table Summary
   mds_rct_df = reactive({
     samp = all_sample
     print(samp)
     f = poly_stats$ID[samp]
     idx = mds$FID[f]
     #  print(input$pheno_select)
    if(input$phenotypes == "URATE"){
      data = merge(urate,mds[idx,],by=1)
      print(data)
      data.frame(ID=data[,1],X=data[,(as.numeric(input$x_pca)+4)],Y=data[,(as.numeric(input$y_pca)+4)],FACTOR=factor(data[,2]))
    }else{
      data.frame(ID=mds$FID[idx],X=mds[idx,(as.numeric(input$x_pca)+3)],Y=mds[idx,(as.numeric(input$y_pca)+3)],FACTOR=factor(phenotypes[idx,names(phenotypes) == input$phenotypes]))
    }
   })
#reactive({print(mds_rct_df(),TRUE)})
 reactive ({ mds_rct_df %>% ggvis(x=~X,y=~Y, key:=~ID,fill=~FACTOR) %>% layer_points() %>%
               add_tooltip(all_values,'hover')}) %>% bind_shiny("mds_plots")
   

})
