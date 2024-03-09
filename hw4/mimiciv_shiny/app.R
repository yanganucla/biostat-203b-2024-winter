library(shiny)
library(tidyverse)
library(dplyr)
library(lubridate)
library(bigrquery)
library(DBI)
library(gt)
library(gtsummary)
library(tidyverse)

mimic_icu_cohort <- readRDS("./mimic_icu_cohort.rds")
# path to the service account token 
satoken <- "biostat-203b-2024-winter-313290ce47a6.json"
# BigQuery authentication using service account
bq_auth(path = satoken)
# connect to the BigQuery database `biostat-203b-2024-winter.mimic4_v2_2`
con_bq <- dbConnect(
  bigrquery::bigquery(),
  project = "biostat-203b-2024-winter",
  dataset = "mimic4_v2_2",
  billing = "biostat-203b-2024-winter"
)
con_bq

# Load your data
sid_adt <- tbl(con_bq, "transfers") 
sid_lab <- tbl(con_bq, "labevents") 
d_icd_procedures <- tbl(con_bq, "d_icd_procedures") 
sid_proc <- tbl(con_bq, "procedures_icd") %>%
  left_join(d_icd_procedures, by = c("icd_code", "icd_version")) 
d_icd_diagnoses <- tbl(con_bq, "d_icd_diagnoses") 
sid_diag <- tbl(con_bq, "diagnoses_icd") %>%
  left_join(d_icd_diagnoses, by = c("icd_code", "icd_version")) 

patientID  <- mimic_icu_cohort %>%
  select(subject_id) %>%
  collect() %>%
  pull(subject_id)
  
# Define UI for dataset viewer app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("MIMIC-IV ICU Cohort EDA"),
  h4("Author: Yang An"),
  
  # Sidebar layout with input and output definitions ----
  tabsetPanel(
    tabPanel("Patient characteristics",
             sidebarLayout(
               sidebarPanel(
                 selectInput("variable", "Variable of interest",
                             choices = c(
                               "First care unit" = "first_careunit",
                               "Last care unit" = "last_careunit",
                               "Admission type" = "admission_type",
                               "Admission location" = "admission_location",
                               "Discharge location" = "discharge_location",
                               "Gender" = "gender",
                               "Race" = "race",
                               "Age" = "anchor_age",
                               "Age group" = "anchor_year_group",
                               "Martial status" = "marital_status",
                               "Language" = "language",
                               "Insurance" = "insurance",
                               "Lab Events" = "labevents",
                               "Chart Events" = "chartevents"
                             )),
                 checkboxInput("remove", "Remove outliers in IQR method for measurements?")
               ),
               mainPanel(
                 plotOutput("cohort_plot")
               )
             )),
    tabPanel("patient's ADT and ICU stay information", fluid = TRUE,
             sidebarLayout(
               sidebarPanel(
                 selectInput("patientID", "Patient ID", choices = 
                               patientID)),
               mainPanel(
                 plotOutput("adt_icu")
               )
             ))
  )
)


# Define server logic to summarize and view selected dataset ----
server <- function(input, output) {
  
  # First tab
  output$cohort_plot <- renderPlot({
    variable <- input$variable
    
    if(variable %in% c("labevents", "chartevents")) {
      if(variable == "labevents") {
        data <- mimic_icu_cohort %>%
          select(potassium, sodium, glucose, creatinine, bicarbonate, chloride) %>%
          pivot_longer(cols = c("potassium", "sodium", "glucose", "creatinine", 
                                "bicarbonate", "chloride"), 
                       names_to = "variable", values_to = "value")
      } else {
        data <- mimic_icu_cohort %>%
          select(`respiratory rate`, `heart rate`, 
                 `non invasive blood pressure systolic`, 
                 `non invasive blood pressure diastolic`, 
                 `temperature fahrenheit`) %>%
          pivot_longer(cols = c("respiratory rate", "heart rate", 
                                "non invasive blood pressure systolic", 
                                "non invasive blood pressure diastolic", 
                                "temperature fahrenheit"),
                       names_to = "variable", values_to = "value")
      }
      
      if(input$remove == FALSE) {
        data %>%
          ggplot(aes(x = value, y = variable)) +
          geom_boxplot(notch=TRUE) +
          xlim(0, 250) +
          theme_minimal()
      } else { 
        data %>%
          ggplot(aes(x = value, y = variable)) +
          geom_boxplot(notch=TRUE, outlier.shape = NA) +
          xlim(0, 250) +
          theme_minimal()
      }
    } else {
      data <- mimic_icu_cohort %>%
        select(variable)
      data %>%
        ggplot(aes_string(y = variable)) +
        geom_bar() +
        theme_minimal()
    }
  })
  
  
  # second tab

  
  reactiveData <- reactive({
    req(input$patientID)
    sid <- as.numeric(input$patientID)
    
  h3_list <- list(
    sid = sid,
    sid_adt = sid_adt %>%
      filter(subject_id == sid) %>%
      collect(),
    sid_lab = sid_lab %>%
      filter(subject_id == sid) %>%
      collect(),
    sid_proc = sid_proc %>%
      filter(subject_id == sid) %>%
      collect(),
    sid_diag = sid_diag %>%
      filter(subject_id == sid) %>%
      collect()
  )
  
  return(h3_list)
  })


    # Plotting
    output$adt_icu <- renderPlot({
      data_list <- reactiveData()
      req(data_list)
      sid <- data_list$sid
      sid_adt <- data_list$sid_adt
      sid_lab <- data_list$sid_lab
      sid_proc <- data_list$sid_proc
      sid_diag <- data_list$sid_diag
    
      
      ggplot() +
        geom_segment(
          data = sid_adt %>%
            filter(eventtype != "discharge"), 
          aes(x = intime, xend = outtime, y = "ADT", yend = "ADT", 
              color = careunit, linewidth = str_detect(careunit, "(ICU|CCU)"))
        ) +
        geom_point(data = sid_lab %>% distinct(charttime, .keep_all = TRUE), 
                   aes(x = charttime, y = "Lab"), shape = '+', size = 5) +
        geom_jitter(data = sid_proc, aes(x = chartdate + hours(12), 
                                         y = "Procedure", shape = 
                                           str_sub(long_title, 1, 25)), 
                    size = 3, height = 0) +
        labs(
          title = paste(
            "Patient", sid , ",",
            mimic_icu_cohort$gender, ",",
            mimic_icu_cohort$anchor_age + year(mimic_icu_cohort$admittime[1]) 
            - mimic_icu_cohort$anchor_year, 
            "years old,",
            str_to_lower(mimic_icu_cohort$race[1])
          ),
          subtitle = paste(str_to_lower(sid_diag$long_title[1:3]), 
                           collapse = "\n"),
          x = "Calendar Time",
          y = "",
          color = "Care Unit",
          shape = "Procedure"
        ) +
        guides(linewidth = "none") +
        scale_y_discrete(limits = rev) +
        theme_light() +
        theme(legend.position = "bottom", legend.box = "vertical")
    })
}



# Create Shiny app ----
shinyApp(ui, server)
