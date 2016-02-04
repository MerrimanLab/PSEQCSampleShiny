library(shiny)
library(ggvis)
library(dplyr)
#options(AmazonS3=c('AKIAIBWPAL7F24QILCNQ'='5gaTpC5/igl27fPk/rTXotDOxnlLosr6P0dByZ78'))
#s3Load("resquencingstorage/poly_stats.RData")
#ds=read.table("plink.mds",header=T)
#phenotypes=read.table("phenotypes_filter.txt",header=T)
#urate=read.table("pheno_euro.txt",header=F)
#colnames(urate) = c("name","hyper")
options(shiny.maxRequestSize=120*1024^2) 
all_values = function(x) {
  if(is.null(x)) return(NULL)
  #stats = stats()
  print("TEST")
  row = stats[stats$FID==x$ID, ]
  paste0(names(row), ": ", format(row), collapse = "<br />")
}
remove_values = function(x){
  if(is.null(x)) return(NULL)
 # paste0(length(all_sample))
 # print(x$ID)
 ## print(all_sample)
  #print(which(x$ID == all_sample))
 # stats = stats()
  index = which(x$ID == stats$FID)
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


# Define server logic required to plot various variables against mpg
shinyServer(function(input, output) {
  stats = reactive({
    if (is.null(input$datafile)){
      return(NULL)
    }
    infile = input$datafile
    stats_input = read.table(infile$datapath,header=T)
    all_sample <<- 1:length(stats_input$IID)
    print(all_sample)
    return(stats_input)
    })

  observe ({
    input$reset_samples
    stats = stats()
    
    all_sample <<- 1:length(poly_stats$ID)  
  })
  
  output$qc_table = renderDataTable({
    stats = stats()
    if(is.null(stats)){
      return(NULL)
    }
   # print(colnames(stats))
    stats[,input$show_vars, drop=FALSE]
  }, options = list(orderClasses = TRUE))
   
   poly_rct_df = reactive({
     samp=all_sample
     print(samp)
     stats = stats()
     if(is.null(stats)){
       return(NULL)
     }
      input$refresh_samples
      input$reset_samples
    #  print(samp)
    #  print(stats)
      if(is.null(input$first_field)){
        data.frame(ID=stats$FID[samp],X=stats[samp ,names(stats) == "NVAR"],
                    Y=stats[samp ,names(stats) == "NALT"])
      }else{
        (data.frame(ID=stats$FID[samp],X=stats[samp ,names(stats) == input$first_field],
                              Y=stats[samp ,names(stats) == input$second_field]))
   }
})
  axis_x = reactive({
    input$first_field
  })
  axis_y = reactive({
    input$second_field
  })
 observe({
   if(is.null(poly_rct_df())){
     data.frame(X=0,Y=0) %>% ggvis(x=~X, y=~Y) %>% bind_shiny("qc_plot")
   }else{
     df = poly_rct_df()
     stats <-- df
     df %>% ggvis(x=~X,y=~Y, key:=~ID) %>% layer_points() %>%
     add_tooltip(all_values,'hover') %>% add_tooltip(remove_values,"click") %>% add_axis("x",title=axis_x()) %>% add_axis("y", title=axis_y())  %>% bind_shiny("qc_plots") 
   }})
  # Create Shiny variable to allow exploration of the QC data.  
   output$download_s <- downloadHandler(
     
      filename = "samples.txt",
      content = function(file) {
        stats = stats()
        if(is.null(stats)){NULL}else{
        write.table(stats$FID[all_sample], file,row.names=F, col.names=F) 
        }
      } 
    )

  reactive_summary = reactive ({
    stats = stats()
    if(is.null(stats)){
      return(NULL)
    }
    samp = all_sample
    input$first_field
    input$second_field
    input$refresh_samples
    input$reset_samples
    idx = which(names(stats)== "NALT")
    summary(stats[samp,idx:ncol(stats)])
  })
  output$indiv_table <- renderTable(reactive_summary())
   # QC table Summary
   mds_rct_df = reactive({
     stats = stats()
     if(is.null(stats)){
       return(NULL)
     }
     samp = all_sample
  #   print("MIGHT BE A MDS problem")
     #print(idx)
     return(NULL)
    # data.frame(ID=stats$FID[samp],X=mds[samp,(as.numeric(input$x_pca)+3)],Y=mds[idx,(as.numeric(input$y_pca)+3)],FACTOR=factor(phenotypes[idx,names(phenotypes) == input$phenotypes]))
   })
#reactive({print(mds_rct_df(),TRUE)})
 observe({
   print(mds_rct_df())
  if(is.null(mds_rct_df())){
    print("LOL")
    data.frame(X=0,Y=0) %>% ggvis(x=~X, y=~Y) %>% bind_shiny("mds_plots")
  }else{
    mds_rct_df %>% ggvis(x=~X,y=~Y, key:=~ID,fill=~FACTOR) %>% layer_points() %>%
              add_tooltip(all_values,'hover') %>% bind_shiny("mds_plots")
  }})
 output$show_vars = renderUI({
   stats = stats()
   if(is.null(stats)){
     return(NULL)
   }
 checkboxGroupInput('show_vars',"Columns in polynesians stats file to show:", names(stats),
                    selected = names(stats)) 
})
 
 output$page_two_first = renderUI({
   stats = stats()
   if(is.null(stats)){
     return(NULL)
   }
   #print("Creating this UIOUtput")
   idx = which(names(stats) == "NALT")
   selectInput("first_field","First Field",
               choices=names(stats)[idx:length(names(stats))])
 })
output$page_two_second = renderUI({
  stats = stats()
  if(is.null(stats)){
    return(NULL)
  }
#  print("Creating this UIOUtput")
  idx = which(names(stats) == "NALT")
  selectInput("second_field","Second Field",
              choices=names(stats)[idx:length(names(stats))])
})
})
