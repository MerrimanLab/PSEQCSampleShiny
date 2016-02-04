#library(RAmazonS3)
library(shiny)
library(ggvis)
#options(AmazonS3=c('AKIAIBWPAL7F24QILCNQ'='5gaTpC5/igl27fPk/rTXotDOxnlLosr6P0dByZ78'))
#s3Load("resquencingstorage/poly_stats.RData")
# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("PSEQC - Samples"),
  sidebarPanel(
    fileInput('datafile', 'Choose PSEQC sample metrics input file',
              accept="text"),
    conditionalPanel(condition="input.conditionedPanels == 'QC Table'"
                     ,uiOutput('show_vars')
  ),
    conditionalPanel(condition = "input.conditionedPanels == 'IndividualPlots'",
                   uiOutput("page_two_first")
  ),
    conditionalPanel(condition = "input.conditionedPanels == 'IndividualPlots'",
                     uiOutput("page_two_second")
  ),
  conditionalPanel(condition = "input.conditionedPanels == 'IndividualPlots'",
                   actionButton("refresh_samples","Refresh Plot"
                   )
  ),
   conditionalPanel(condition = "input.conditionedPanels == 'IndividualPlots'",
                     downloadButton("download_s","Download Sample Remaining"
                      )
  ),
  conditionalPanel(condition = "input.conditionedPanels == 'IndividualPlots'",
                   actionButton("reset_samples","Reset deleted Samples"
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