library(shiny)
library(shinydashboard)
library(bslib)
library(ggplot2)
library(dplyr)
library(lubridate)
library(plotly)
library(shinyjs)

# read data
sales_data <- read.csv("data/raw/supermarket_sales.csv")
sales_data$Date <- as.Date(sales_data$Date, format="%m/%d/%Y")
sales_data$Hour <- as.POSIXlt(strptime(sales_data$Time, format="%H:%M"))$hour

# UI 
ui <- fluidPage(
  title = "Supermarket ProductLine Insight",
  theme = bs_theme(bootswatch = "minty"),
  
  tags$style(HTML("
    body {
      padding: 15px;
    }
    .container {
      margin-top: 20px;
      margin-bottom: 20px;
      padding: 0 15px;
    }
    .card {
      margin-bottom: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
    }
    .plot-container {
      background-color: white;
      padding: 15px;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0,0,0,0.1);
      margin-bottom: 20px;
    }
  ")),
  
  tags$head(
    tags$style(HTML("
    .plot-container {
      border: none !important;
      box-shadow: none !important;
      padding: 0 !important;
    }
    
    .container .container {
      padding: 0 !important;
      margin: 0 !important;
      border: none !important;
      width: 100% !important;
    }
  "))
  ),
  
  
  
  # first row
  div(class = "container",
      div(class = "row",
      # tittle
          div(class = "col-md-3", h2("Supermarket ProductLine Insight")),
      # KPI Cards
          div(class = "col-md-3", uiOutput("total_sales")),
          div(class = "col-md-3", uiOutput("total_gross_profit")),
          div(class = "col-md-3", uiOutput("avg_ticket_sales"))
      )
  ),
  
  # second row
  div(class = "container",
      div(class = "row",
          div(class = "col-md-3",
              # filter
              div(class = "card",
                  div(class = "card-body",
                      h4("Filters", style = "margin-top: 0; margin-bottom: 15px; color: #495057;"),
                      radioButtons("city_filter", "Select City:", 
                                   choices = c("All", unique(sales_data$City)),
                                   selected = "All"),
                      radioButtons("month_filter", "Select Month:",
                                   choices = list("All" = "all","January" = "1", "February" = "2", "March" = "3"),
                                   selected = "all")
                  )
              )
          ),

          div(class = "col-md-9", 
              div(class = "plot-container",
                  div(class = "row gx-0",
                      div(class = "col-md-5", style = "padding-right: 0px;", plotOutput("weekly_trend", height = "350px")),
                      div(class = "col-md-7", style = "padding-left: 0px;", plotOutput("volume_change_trend", height = "350px", width = "95%"))
                  )
              )
          ))),
  
  # third row
  div(class = "container",
      div(class = "row",
          div(class = "col-md-3", 
              uiOutput("top_female_card"),
              uiOutput("top_male_card"),
              uiOutput("top_all_card")
          ),
          div(class = "col-md-5", 
              div(class = "plot-container", plotlyOutput("sales_by_gender"))
          ),
          div(class = "col-md-4",
              div(class = "plot-container", 
                  uiOutput("customer_rating")
              )
          )
      )
  )
)
# Server
server <- function(input, output) {
  
  dashboard_theme <- function() {
    theme_minimal() +
      theme(
        plot.title = element_text(size = 16, face = "bold", color = "#495057", margin = margin(b = 15)),
        axis.title = element_text(size = 12, color = "#6c757d"),
        axis.text = element_text(size = 10, color = "#6c757d"),
        legend.position = "bottom",
        legend.title = element_blank(),
        panel.grid.major = element_line(color = "#e9ecef"),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white"),
        plot.background = element_rect(fill = "white", color = NA),
        plot.margin = margin(15, 15, 15, 15)
      )
  }
  
  no_legend_theme <- function() {
    dashboard_theme() +
      theme(legend.position = "none")
  }
  
  
  # filter
  filtered_data <- reactive({
    data <- sales_data
    if (input$city_filter != "All") {
      data <- data |> filter(City == input$city_filter)
    }
    if (input$month_filter != "all") {
      data <- data |> filter(month(Date) == as.numeric(input$month_filter))
    }
    if(nrow(data) == 0) return(NULL) 
    return(data)
  })
  
  
  # KPI cards
  output$total_sales <- renderUI({
    req(filtered_data())
    value <- paste0("$", round(sum(filtered_data()$Total, na.rm = TRUE) / 1000, 2), "k")
    
    div(class = "card", style = "height: 100%;",
        div(class = "card-body", style = "padding: 15px; display: flex; align-items: center;",
            # Left side - Icon
            div(style = "margin-right: 20px;",
                icon("chart-line", style = "font-size: 40px; color: #ffcd56;")
            ),
            # Right side - Text content
            div(
              h3(style = "margin-top: 0; font-size: 22px; font-weight: bold; margin-bottom: 5px;", value),
              p(style = "color: #666; margin: 0; font-size: 16px;", "Total Net Sales")
            )
        )
    )
  })
  
  output$total_gross_profit <- renderUI({
    req(filtered_data())
    value <- paste0("$", round(sum(filtered_data()$gross.income, na.rm = TRUE)/1000, 2),"k")
    
    div(class = "card", style = "height: 100%;",
        div(class = "card-body", style = "padding: 15px; display: flex; align-items: center;",
            # Left side - Icon
            div(style = "margin-right: 20px;",
                icon("dollar", style = "font-size: 40px; color: #4bc0c0;")
            ),
            # Right side - Text content
            div(
              h3(style = "margin-top: 0; font-size: 22px; font-weight: bold; margin-bottom: 5px;", value),
              p(style = "color: #666; margin: 0; font-size: 16px;", "Total Gross Profit")
            )
        )
    )
  })
  
  output$avg_ticket_sales <- renderUI({
    req(filtered_data())
    avg_ticket <- sum(filtered_data()$Total, na.rm = TRUE) / nrow(filtered_data())
    value <- paste0("$", round(avg_ticket, 2))
    
    div(class = "card", style = "height: 100%;",
        div(class = "card-body", style = "padding: 15px; display: flex; align-items: center;",
            # Left side - Icon
            div(style = "margin-right: 20px;",
                icon("receipt", style = "font-size: 40px; color: #ff9f9f;")
            ),
            # Right side - Text content
            div(
              h3(style = "margin-top: 0; font-size: 22px; font-weight: bold; margin-bottom: 5px;", value),
              p(style = "color: #666; margin: 0; font-size: 16px;", "Avg Ticket Sales")
            )
        )
    )
  })
  
  # Weekly Trend & Net Sales
  output$weekly_trend <- renderPlot({
    req(filtered_data())
    filtered_data() |>
      group_by(week = floor_date(Date, "week"), Product.line) |>
      summarise(total_sales = sum(Total), .groups = 'drop') |>
      ggplot(aes(x = week, y = total_sales, color = Product.line)) +
      geom_line(size = 1) +
      geom_point(size = 2) +
      labs(title = "Weekly Net Sales Trend", x = "Week", y = "Net Sales") +
      scale_color_brewer(palette = "Set2") +
      dashboard_theme() +
      theme(legend.position = "none")
    
  })
  
  output$volume_change_trend <- renderPlot({
    req(filtered_data())
    filtered_data() |>
      group_by(week = floor_date(Date, "week"), Product.line) |>
      summarise(volume = sum(Quantity), .groups = 'drop') |>
      ggplot(aes(x = week, y = volume, color = Product.line)) +
      geom_line(size = 1) +
      geom_point(size = 2) +
      labs(title = "Weekly Volume Trend", x = "Week", y = "Volume") +
      scale_color_brewer(palette = "Set2") +
      dashboard_theme() +
      theme(legend.position = "right",
            legend.title = element_blank(),
            legend.box.spacing = unit(0, "cm"))
  })
  
  
  # Sales by Gender
  output$sales_by_gender <- renderPlotly({
    req(filtered_data())
    p <- filtered_data() |>
      group_by(Product.line, Gender) |>
      summarise(total_sales = sum(Total), .groups = 'drop') |>
      ggplot(aes(x = Product.line, y = total_sales, fill = Gender,
                 text = paste("Product Line:", Product.line, 
                              "<br>Gender:", Gender, 
                              "<br>Sales: $", round(total_sales, 2)))) +
      geom_bar(stat = "identity", position = "dodge") +
      labs(title = "Sales by Gender", y = "Net Sales", x = "Product Line") +
      theme(legend.position = "none",
            axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = "text") |>
      layout(
        hoverlabel = list(bgcolor = "white", font = list(color = "black")),
        legend = list( #the legend is actually not showing but it's fine
          orientation = "h",  
          xanchor = "right",  
          x = 0.95,           
          y = 0.98,           
          yanchor = "top",    
          bgcolor = "rgba(255, 255, 255, 0.5)", 
          bordercolor = "rgba(0, 0, 0, 0)"      
        ),
        margin = list(t = 50)  
      )
  })
  
  # top femae purchase
  output$top_female_card <- renderUI({
    req(filtered_data())
    female_data <- filtered_data() |>
      filter(Gender == "Female") |>
      group_by(Product.line) |>
      summarise(total_sales = sum(Total), .groups = 'drop')
    
    top_female <- female_data |>
      arrange(desc(total_sales)) |>
      slice(1)
    
    div(class = "card", style = "margin-bottom: 20px;",
        div(class = "card-body", style = "padding: 15px; display: flex; align-items: center;",
            # icon
            div(style = "margin-right: 20px;",
                icon("female", style = "font-size: 40px; color: #FF6B6B;")
            ),
            # text
            div(
              h4(style = "margin-top: 0; font-size: 16px; font-weight: bold; margin-bottom: 5px;", "Top Female Purchase"),
              p(style = "color: #666; margin: 0; font-size: 18px;", top_female$Product.line),
              p(style = "color: #666; margin: 0; font-size: 14px;", paste0("$", round(top_female$total_sales/1000, 1),"k"))
            )
        )
    )
  })
  
  # top male purchase
  output$top_male_card <- renderUI({
    req(filtered_data())
    male_data <- filtered_data() |>
      filter(Gender == "Male") |>
      group_by(Product.line) |>
      summarise(total_sales = sum(Total), .groups = 'drop')
    
    top_male <- male_data |>
      arrange(desc(total_sales)) |>
      slice(1)
    
    div(class = "card", style = "margin-bottom: 20px;",
        div(class = "card-body", style = "padding: 15px; display: flex; align-items: center;",
            # icon
            div(style = "margin-right: 20px;",
                icon("male", style = "font-size: 40px; color: #4ECDC4;")
            ),
            # text
            div(
              h4(style = "margin-top: 0; font-size: 16px; font-weight: bold; margin-bottom: 5px;", "Top Male Purchase"),
              p(style = "color: #666; margin: 0; font-size: 18px;", top_male$Product.line),
              p(style = "color: #666; margin: 0; font-size: 14px;", paste0("$", round(top_male$total_sales/1000, 1),"k"))
            )
        )
    )
  })
  
  # top all purchase
  output$top_all_card <- renderUI({
    req(filtered_data())
    all_data <- filtered_data() |>
      group_by(Product.line) |>
      summarise(total_sales = sum(Total), .groups = 'drop')
    
    top_all <- all_data |>
      arrange(desc(total_sales)) |>
      slice(1)
    
    div(class = "card", style = "margin-bottom: 20px;",
        div(class = "card-body", style = "padding: 15px; display: flex; align-items: center;",
            # icon
            div(style = "margin-right: 20px;",
                icon("shopping-cart", style = "font-size: 30px; color: #6C757D;")
            ),
            # text
            div(
              h4(style = "margin-top: 0; font-size: 16px; font-weight: bold; margin-bottom: 5px;", "Top All Purchase"),
              p(style = "color: #666; margin: 0; font-size: 18px;", top_all$Product.line),
              p(style = "color: #666; margin: 0; font-size: 14px;", paste0("$", round(top_all$total_sales/1000, 1),"k"))
            )
        )
    )
  })
  
  
  # Rating Chart
  output$customer_rating <- renderUI({
    req(filtered_data())
    member_rating <- min(max(mean(filtered_data()$Rating[filtered_data()$Customer.type == "Member"], na.rm = TRUE) * 10, 0), 100)
    normal_rating <- min(max(mean(filtered_data()$Rating[filtered_data()$Customer.type == "Normal"], na.rm = TRUE) * 10, 0), 100)
    
    tagList(
      div(class = "plot-container",
          div(style = "display: flex; align-items: center; margin-bottom: 15px;",
              h5("Customer Rating", style = "margin: 0; color: #495057;"),
              icon("thumbs-up", style = "margin-left: 10px; color: #6c757d;")
          ),
          div(style = "display: flex; justify-content: space-between; margin-top: 20px;",
              # Member
              div(style = "text-align: center; width: 45%;",
                  div(style = paste0("width: 120px; height: 120px; border-radius: 50%; background: conic-gradient(",
                                     "#2196F3 0% ", member_rating, "%, #f1f1f1 ", member_rating, "% 100%);",
                                     "display: inline-flex; justify-content: center; align-items: center; position: relative;"),
                      div(style = "width: 80px; height: 80px; background: white; border-radius: 50%; display: flex; justify-content: center; align-items: center;",
                          span(style = "font-size: 22px; font-weight: bold; color: #333;", 
                               paste0(round(member_rating), "%"))
                      )
                  ),
                  h5("Member", style = "margin-top: 10px;")
              ),
              # Normal
              div(style = "text-align: center; width: 45%;",
                  div(style = paste0("width: 120px; height: 120px; border-radius: 50%; background: conic-gradient(",
                                     "#2196F3 0% ", normal_rating, "%, #f1f1f1 ", normal_rating, "% 100%);",
                                     "display: inline-flex; justify-content: center; align-items: center; position: relative;"),
                      div(style = "width: 80px; height: 80px; background: white; border-radius: 50%; display: flex; justify-content: center; align-items: center;",
                          span(style = "font-size: 22px; font-weight: bold; color: #333;", 
                               paste0(round(normal_rating), "%"))
                      )
                  ),
                  h5("Normal", style = "margin-top: 10px;")
              )
          ),
          div(style = "text-align: center; margin-top: 20px; font-size: 14px; color: #6c757d;",
              p("Developed by Zoe Ren"),
              p("GitHub Repository: https://github.ubc.ca/mds-2024-25/DSCI_532_individual-assignment_zr2884"),
              p("Last updated: 2025-03-15")
          )
      )
    )
  })
}

shinyApp(ui, server)
