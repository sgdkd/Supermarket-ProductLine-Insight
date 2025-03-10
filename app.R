library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(lubridate)

# read data
sales_data <- read.csv("data/supermarket_sales.csv")
sales_data$Date <- as.Date(sales_data$Date, format="%m/%d/%Y")
sales_data$Hour <- as.POSIXlt(strptime(sales_data$Time, format="%H:%M"))$hour

# UI 
ui <- page_fluid(
  title = "Supermarket Sales Dashboard",
  theme = bs_theme(bootswatch = "minty"),
  
  layout_column_wrap(
    width = 1/4,
    value_box("Total Sales", paste0("$", round(sum(sales_data$Total), 2)), showcase = icon("dollar-sign")),
    value_box("Total Transactions", nrow(sales_data), showcase = icon("shopping-basket")),
    value_box("Avg Ticket Size", paste0("$", round(mean(sales_data$Total), 2)), showcase = icon("receipt")),
    value_box("Total Gross Income", paste0("$", round(sum(sales_data$gross.income), 2)), showcase = icon("chart-line"))
  ),
  
  div(class = "container",
      div(class = "row",
          div(class = "col-md-6", plotOutput("sales_trend")),
          div(class = "col-md-6", plotOutput("customer_type"))
      ),
      div(class = "row",
          div(class = "col-md-6", plotOutput("product_income"))
      ),
      div(class = "row",
          div(class = "col-md-6", plotOutput("hourly_sales")),
          div(class = "col-md-6", plotOutput("daily_sales"))
      ),
      div(class = "row",
          div(class = "col-md-6", plotOutput("branch_sales")),
          div(class = "col-md-6", plotOutput("city_sales"))
      )
  ),
  
  div(class = "container",
      div(class = "row",
          div(class = "col-md-6",
              radioButtons("gender_filter", "Select Gender:", 
                           choices = list("All" = "all", "Female" = "Female", "Male" = "Male"),
                           selected = "all"),
              plotOutput("product_income")
          )
      )
  )
)

# Server 
server <- function(input, output) {
  
  # weekly sales trend
  output$sales_trend <- renderPlot({
    sales_data %>%
      group_by(week = floor_date(Date, "week")) %>%
      summarise(total_sales = sum(Total)) %>%
      ggplot(aes(x = week, y = total_sales)) +
      geom_line(color = "blue") +
      geom_point() +
      labs(title = "Weekly Sales Trend", x = "Week", y = "Sales")
  })
  
  # customer
  output$customer_type <- renderPlot({
    sales_data %>%
      group_by(Customer.type) %>%
      summarise(total_sales = sum(Total)) %>%
      ggplot(aes(x = Customer.type, y = total_sales, fill = Customer.type)) +
      geom_bar(stat = "identity") +
      labs(title = "Customer Type Sales Distribution", x = "Customer Type", y = "Sales")
  })
  
  # gross profit
  output$product_income <- renderPlot({
    filtered_data <- sales_data
    if (input$gender_filter != "all") {
      filtered_data <- filtered_data %>% filter(Gender == input$gender_filter)
    }
    
    filtered_data %>%
      group_by(Product.line) %>%
      summarise(gross_income = sum(gross.income)) %>%
      ggplot(aes(x = "", y = gross_income, fill = Product.line)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar(theta = "y") +
      labs(title = "Product Line Gross Income", x = NULL, y = NULL)
  })
  
  # branch
  output$branch_sales <- renderPlot({
    sales_data %>%
      group_by(Branch) %>%
      summarise(total_sales = sum(Total)) %>%
      ggplot(aes(x = "", y = total_sales, fill = Branch)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar(theta = "y") +
      labs(title = "Sales by Branch", x = NULL, y = NULL)
  })
  
  # city
  output$city_sales <- renderPlot({
    sales_data %>%
      group_by(City) %>%
      summarise(total_sales = sum(Total)) %>%
      ggplot(aes(x = "", y = total_sales, fill = City)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar(theta = "y") +
      labs(title = "Sales by City", x = NULL, y = NULL)
  })
}

shinyApp(ui, server)