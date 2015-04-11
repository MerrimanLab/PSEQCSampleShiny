#library(RAmazonS3)
library(shiny)
library(ggvis)
#options(AmazonS3=c('AKIAIBWPAL7F24QILCNQ'='5gaTpC5/igl27fPk/rTXotDOxnlLosr6P0dByZ78'))
poly_stats = read.table('euro.istats',header=T)
mds=read.table("plink.mds",header=T)
phenotypes=read.table("phenotypes_filter.txt",header=T)
#s3Load("resquencingstorage/poly_stats.RData")
urate=read.table("pheno_euro.txt",header=F)
colnames(urate) = c("name","hyper")
# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Individual QC"),
  sidebarPanel(
    conditionalPanel(condition="input.conditionedPanels == 'QC Table'"
                     ,checkboxGroupInput('show_vars',"Columns in polynesians stats file to show:", names(poly_stats),
    selected = names(poly_stats))
  ),
    conditionalPanel(condition = "input.conditionedPanels == 'IndividualPlots'",
                     selectInput("first_field","First Field",
                      choices=names(poly_stats)[2:length(names(poly_stats))])
  ),
   conditionalPanel(condition = "input.conditionedPanels == 'IndividualPlots'",
                  selectInput("second_field","Second Field",
                              choices=names(poly_stats)[2:length(names(poly_stats))])
  ),
  conditionalPanel(condition = "input.conditionedPanels == 'IndividualPlots'",
                   actionButton("refresh_samples","Refresh Plot",
                   )
  ),
   conditionalPanel(condition = "input.conditionedPanels == 'IndividualPlots'",
                     downloadButton("download_s","Download Sample Remaining",
                      )
  ),
  conditionalPanel(condition = "input.conditionedPanels == 'IndividualPlots'",
                   actionButton("reset_samples","Reset deleted Samples",
                   )
    
  ),
  
   conditionalPanel(condition = "input.conditionedPanels == 'MDS'",
                  selectInput("x_pca","X AXIS",
                              choices=c(1:4))
  ),
  conditionalPanel(condition = "input.conditionedPanels == 'MDS'",
                   selectInput("y_pca","Y AXIS",
                               choices=c(2:4))
  
  ),
  conditionalPanel(condition = "input.conditionedPanels == 'MDS'",
                  selectInput("phenotypes","Phenotypes",
                                choices=c("URATE")
                              )
  )

  ),
  mainPanel(
      tabsetPanel(
        tabPanel('QC Table',
          dataTableOutput("qc_table")),
        tabPanel('IndividualPlots',
          h4("Click to Remove Sample"),
          ggvisOutput('qc_plots'),
          h4("Summary Table"),
          tableOutput('indiv_table')),
        tabPanel('MDS',
          ggvisOutput("mds_plots")),
        id= "conditionedPanels"
      )
  )
)
) 