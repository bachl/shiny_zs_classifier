library(shiny)
source("prompt_checker_function.R")

ui <- fluidPage(
  titlePanel("Zero-Shot Klassifikation mit der OpenAI API"),
  
  sidebarLayout(
    sidebarPanel(
      textInput("api_key", "API Key:"),
      numericInput("max_tokens", "Maximum of tokens:", value = 80L),
      textAreaInput("prompt", "Prompt:", rows = 8,
                    value = 'I will show you a social media comment. Decide whether it is sexist or not sexist. This task defines sexism as: "Any abuse or negative sentiment that is directed towards women based on their gender, or on the combination of their gender with one or more other identity attributes (e.g. Black women, Muslim women, Trans women)."\n\nYou should assign the comment a numeric label, 1 or 0.\n1. The comment is sexist.\n0. The comment is not sexist.\n\nAnswer in JSON format with the template below.\n\n{\n  \"label\": 1,\n  \"motivation\": \"Briefly explain why you chose this label.\"\n}\n'),
      fileInput("file", "Choose CSV File with ';' as separator:",
                accept = c("text/csv",
                           "text/comma-separated-values,text/plain",
                           ".csv")),
      textInput("column", "Name of column with texts to classify:", "text"),
      actionButton("submit", "Submit"),
      downloadButton("download", "Download results as .csv file")
    ),
    mainPanel(
      tableOutput("results")
    )
  )
)

server <- function(input, output, session) {
  
  results <- eventReactive(input$submit, {
    txts = read.csv2(input$file$datapath)[[input$column]]
    classify(api_key = input$api_key,
             text_file = txts,
             prompt_file = input$prompt,
             max_tokens = input$max_tokens)
  })
  
  output$results <- renderTable({
    results()
  })
  
  output$download <- downloadHandler(
    filename = function() {
      paste("results-", Sys.Date(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv2(results(), file, row.names = FALSE)
    }
  )
}

shinyApp(ui, server)
