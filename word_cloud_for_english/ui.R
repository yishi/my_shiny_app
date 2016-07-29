
################################################
###  word cloud shiny app for english
################################################

library(tm)
library(wordcloud)


shinyUI(pageWithSidebar(
  titlePanel("Word Cloud for English"), 
    
    sidebarPanel(
      
      p('You could upload your text to do word cloud, instead the example text.'),
      
      fileInput('file', 'Choose TXT File',
                accept=c('text/csv', 'text/comma-separated-values,text/plain', 
                         '.txt')),
      tags$hr(),
      p('You could choose weight methods: count, term frequency, or tf-idf.'),
      p('Our example text is one document, so we treat one paragraph as one document to weight the word frequency.'),
      selectInput('weight', 'Choose weight methods:', 
                  choices = c('count' = 'control', 'tf' = 'control2', 'tf-idf' = 'control3'), 
                  selected = 'control'),
      tags$hr(),
      p('You could choose how many high frequency word to use, the default value is top 100'),
      numericInput('obs', "Number of words to view:", 100)
    ),
  
    mainPanel(
      
      tabsetPanel(
        
        #     tabPanel("contents", verbatimTextOutput('contents')),
        tabPanel("Plot", plotOutput("plot")), 
        tabPanel("Word Frequency", verbatimTextOutput("word_frequency"))
      )
    )
    
))
