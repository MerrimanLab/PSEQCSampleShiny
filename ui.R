library(RAmazonS3)
library(shiny)
options(AmazonS3=c('AKIAIBWPAL7F24QILCNQ'='5gaTpC5/igl27fPk/rTXotDOxnlLosr6P0dByZ78'))
poly_stats = read.table('~/eli_resquence/ggvis/poly_stats.istats',header=T)
s3Load("resquencingstorage/poly_stats.RData")

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Resquencing QC"),
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
                              choices=names(poly_stats)[3:length(names(poly_stats))])
  )
  ),
  mainPanel(
      tabsetPanel(
        tabPanel('QC Table',
          dataTableOutput("qc_table")),
        tabPanel('IndividualPlots', 
          ggvisOutput('qc_plots')),
        id= "conditionedPanels"
      )
    )
  )
)