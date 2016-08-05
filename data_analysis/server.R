

#######################################
###  data analysis platform
###  amazon pruduct data as an example
########################################


library(ggplot2)
library(tm)
library(wordcloud)
library(igraph)
library(visNetwork)

shinyServer(function(input, output, session) {
  
  # data 
  dataInput <- reactive({
    
    inFile <- input$file   

    if (is.null(inFile)) {
      
      data = read.csv('data/Best-Sellers-Home-test.csv', 
                      stringsAsFactors = FALSE)
      
    }else{
      
      data <- read.csv(inFile$datapath, stringsAsFactors = FALSE)
    }
    
    # clean the data
    # delete the dollar sign and transform to numeric 
    data$price <- as.numeric(substring(data$price, 2))
    # delete the comma sign and transform to numeric 
    data$reviews <- as.numeric(gsub(pattern = ',', replacement = '', x = data$reviews))
    
    
    data  
    
  })
  
  # activate widgets 
  observe({
    
    cols = names(dataInput())
    
    updateSelectInput(session, 'col2_1', 
                      choices = cols[c(2, 3, 4)], 
                      selected = cols[c(2, 3, 4)][1])
    
    updateSelectInput(session, 'col2_2', 
                      choices = cols[c(2, 3, 4)], 
                      selected = cols[c(2, 3, 4)][2])
    
    updateSelectInput(session, 'col2_3', 
                      choices = cols[c(2, 3, 4)], 
                      selected = cols[c(2, 3, 4)][2])
    
    updateSelectInput(session, 'col3_1', 
                      choices = levels(factor(dataInput()$department)), 
                      selected = levels(factor(dataInput()$department))[1])
    
  })
  
  # output for tab 1 
  output$table1_1 <- DT::renderDataTable(
    DT::datatable({
    dataInput()
  }))
  
  # for tab 2
  
  output$scatter2_1 <- renderPlot({
    gg <- ggplot(dataInput(), aes(x = get(input$col2_1), y = get(input$col2_2), color = department)) +
      geom_point(size = 3) +
      xlab(input$col2_1) +
      ylab(input$col2_2) +
      ggtitle('Scatter Plot')
    
    print(gg)
    
  })
  
  
  output$plot2_2 <- renderPlot({
    gg <- ggplot(dataInput(), aes(x = factor(department), y = get(input$col2_3), color = department)) +
      geom_violin() +
      xlab('department') +
      ylab(input$col2_3) +
      ggtitle('Box Plot')
    
    print(gg)
    
  })
    
  text_tdm <- reactive({
    
    title_text = subset(dataInput(), department == input$col3_1, select = title)
    
    # bag of word 
    wordcorpus <- Corpus(VectorSource(title_text$title))
    
    control <- list(removePunctuation=TRUE, 
                    removeNumbers=TRUE,  
                    wordLengths=c(2, Inf), weighting=weightBin, stopwords=TRUE)
    
    # matrix 
    tdm <- TermDocumentMatrix(wordcorpus, control)
    
    tdm_matrix <- as.matrix(tdm)
    
    tdm_matrix
    
  })
  
  output$plot3_1 <- renderPlot({ 
    
    # frequency of word 
    wordFreq <- sort(rowSums(text_tdm()), decreasing=TRUE)
    
    # word cloud 
    op = par(bg = "lightgray")
    grayLevels <- gray((wordFreq) / (max(wordFreq)))
    wordcloud(words = names(wordFreq), freq = wordFreq, 
              min.freq = 1, random.order = F, 
              colors = grayLevels)
    
    par(op)
    
  })

  output$text3_1 <- renderPrint({
    
    # frequency of word 
    wordFreq <- sort(rowSums(text_tdm()), decreasing=TRUE)
    
    wordFreq[1:20]
    
  })
  
  
  output$plot3_2 <- renderVisNetwork({
    
    # term term matrix 
    term_term <- text_tdm()%*%t(text_tdm())
    
    g <- graph.adjacency(term_term, weighted=T, mode = "undirected")
    # remove loops
    g <- simplify(g)
    # set labels and degrees of vertices
    V(g)$label <- V(g)$name
    V(g)$degree <- degree(g)
    
    # Plot a Graph
    # set seed to make the layout reproducible
    V(g)$label.cex <- 4*V(g)$degree / max(V(g)$degree)
    V(g)$label.color <- rgb(0, 0, .2, .8)
    V(g)$frame.color <- NA
    egam <- (log(E(g)$weight)+.4) / max(log(E(g)$weight)+.4)
    E(g)$color <- rgb(.5, .5, 0, egam)
    E(g)$width <- egam
    
    data <- toVisNetworkData(g)
    visNetwork(nodes = data$nodes, edges = data$edges, 
               main = 'Word Relationship Network') %>% 
      visOptions(highlightNearest = TRUE, nodesIdSelection = TRUE)
    
  })
  
})

