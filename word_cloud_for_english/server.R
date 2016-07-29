

################################################
###  word cloud shiny app for english
################################################

library(tm)
library(wordcloud)


shinyServer(function(input, output) {
  
  dataInput <- reactive({
        
    inFile <- input$file
    
    
    if (is.null(inFile)) {
      
      data_file <- readLines("data/example.txt")
      
    } else {
      
      data_file <- readLines(inFile$datapath)
      
    }
      

    # only one document, but have many paragraph 
    # we treat one paragraph as one document to compute 
    # split the text to  paragraph
    para <- strsplit(data_file, "\\n", fixed = TRUE)
  
    # make a corpus
    wordcorpus <- Corpus(VectorSource(para))
  
    # three weight methods
    
    control <- list(removePunctuation = TRUE,
                    removeNumbers = TRUE, 
                    wordLengths = c(1, Inf), weighting = weightBin,
                    stopwords = TRUE)
    
    
    control2 <- list(removePunctuation = TRUE,
                     removeNumbers = TRUE, 
                     wordLengths = c(1, Inf), weighting = weightTf,
                     stopwords = TRUE)
    
    control3 <- list(removePunctuation = TRUE,
                     removeNumbers = TRUE, 
                     wordLengths = c(1, Inf), weighting = weightTfIdf,
                     stopwords = TRUE)
    
  
  
    # make term document matrix
    tdm <- TermDocumentMatrix(wordcorpus, get(input$weight))    
    
    want_wordFreq <- sort(rowSums(as.matrix(tdm)), decreasing = TRUE)[1:input$obs]
    
    want_wordFreq
    
  })  
  
  output$word_frequency <- renderPrint({
    
    dataInput()
    
  })
  
  output$plot <- renderPlot({

    want_wordFreq <- dataInput()
    

    op = par(bg = "lightgray")
    grayLevels <- gray((want_wordFreq) / (max(want_wordFreq)))
    wordcloud(words = names(want_wordFreq), freq = want_wordFreq, 
              min.freq = 1, random.order = F, 
              colors = grayLevels)
    
    par(op)
    
  }) 

  
})


