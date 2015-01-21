
library(shiny)
poly_stats = read.table('~/eli_resquence/ggvis/poly_stats.istats',header=T)

# Define UI for miles per gallon application
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Resquencing QC"),
  sidebarPanel(
    conditionalPanel(condition="input.conditionedPanels == 'QC Table'"
                     ,checkboxGroupInput('show_vars',"Columns in polynesians stats file to show:", names(poly_stats),
    selected = names(poly_stats))
  ),
    conditionalPanel(condition = "input.conditionedPanels == 'Plots'",
                     selectInput("first_field","First Field",
                      choices=names(poly_stats)[2:length(names(poly_stats))])
  ),
   conditionalPanel(condition = "input.conditionedPanels == 'Plots'",
                  selectInput("second_field","Second Field",
                              choices=names(poly_stats)[2:length(names(poly_stats))])
  )
  ),
  mainPanel(
      tabsetPanel(
        tabPanel('QC Table',
          dataTableOutput("qc_table")),
        tabPanel('IndivualPlots', 
          ggvisOutput('qc_plots')),
        id= "conditionedPanels"
      ),tabPanel("MDSplots")
    )
  )
)