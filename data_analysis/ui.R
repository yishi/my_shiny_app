

#######################################
###  data analysis platform
###  amazon pruduct data as an example
########################################

library(ggplot2)
library(tm)
library(wordcloud)
library(igraph)
library(visNetwork)

shinyUI(fluidPage(
  
  titlePanel("Data Analysis Platform"),
    
  navbarPage("", 
    # tab 1            
    tabPanel("Data", 
             fluidPage(
               
               fluidRow(
                 column(3, fileInput('file', "Please upload your data!", multiple = FALSE, accept = ".csv")), 
                 column(9, DT::dataTableOutput("table1_1"))
                 )
               
               )             
             ), 
    # tab 2     
    tabPanel("Plot", 
             fluidPage(
               
               fluidRow(
                 column(3, selectInput('col2_1', 'Please choose one variable as x:', 'option1'), 
                        br(), 
                        selectInput('col2_2', 'Please choose the other variable as y:', 'option1')
                 ),
                 column(9, plotOutput('scatter2_1'))
                 ),
               
               fluidRow(
                 column(3, selectInput('col2_3', 'Please choose one variable as y:', 'option1')),
                 column(9, plotOutput('plot2_2'))
               )

             )
           ),
    
    # tab 3
    tabPanel("text analysis", 
             fluidPage(
               
               fluidRow(
                 column(3, selectInput('col3_1', 'Please choose one type of department:', 'option1')),
                 column(9, plotOutput('plot3_1'), verbatimTextOutput('text3_1'))
               ),
               
               fluidRow(
                 column(3, p('If two words appeared at the same title, then these two words have relationship.'), 
                        p('You can drag and zoom the plot by your mouse to check the relationships of the words.'), 
                        p('You could also check the word network by the button of select by id.')), 
                 column(9, visNetworkOutput("plot3_2"))
                 )
               
               )
             )
  
  )
  
  ))
