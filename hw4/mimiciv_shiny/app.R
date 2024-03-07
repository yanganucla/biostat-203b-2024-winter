
library(shiny)
library(tidyverse)
library(dplyr)
library(lubridate)

mimic_icu_cohort <- readRDS("mimic_icu_cohort.rds")

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
                 actionButton("update", "update"),
                 checkboxInput("remove", "Remove outliers in IQR method 
                               for measurements?")
               ),
               mainPanel(
                 plotOutput("cohort_plot")
               )
             )),
    tabPanel("patient's ADT and ICU stay information",
             sidebarLayout(
               sidebarPanel(
                 helpText("Select a patient. "),
                 textInput(inputId = "patient_id",
                          label = "Patient ID",
                          value = ""),
                 actionButton("lookup", "Lookup")
               ),
               mainPanel(
                 plotOutput("adt_icu")
               )
             ))
    )
  )


# Define server logic to summarize and view selected dataset ----
server <- function(input, output) {
  
  # first tab
  observeEvent(input$update, {
    if(input$variable == "labevents") {
      data <- mimic_icu_cohort %>%
        select(potassium, sodium, glucose, creatinine, bicarbonate, chloride) %>%
        pivot_longer(cols = c("potassium", "sodium", "glucose", "creatinine", 
                              "bicarbonate", "chloride"), 
                     names_to = "variable", values_to = "value")
      if(input$remove == FALSE) {
        output$cohort_plot <- renderPlot({
          data %>%
            ggplot(aes(x = value, y = variable)) +
            geom_boxplot(notch=TRUE) +
            xlim(0, 250) +
            theme_minimal()
        })
      } else { 
        output$cohort_plot <- renderPlot({
          data %>%
            ggplot(aes(x = value, y = variable)) +
            geom_boxplot(notch=TRUE, outlier.shape = NA) +
            xlim(0, 250) +
            theme_minimal()
        })
      }
    } else if (input$variable == "chartevents") { 
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
      
      if(input$remove == FALSE) {
        output$cohort_plot <- renderPlot({
          data %>%
            ggplot(aes(x = value, y = variable)) +
            geom_boxplot(notch=TRUE) +
            xlim(0, 250) +
            theme_minimal()
        })
      } else { 
        output$cohort_plot <- renderPlot({
          data %>%
            ggplot(aes(x = value, y = variable)) +
            geom_boxplot(notch=TRUE, outlier.shape = NA) +
            xlim(0, 250) +
            theme_minimal()
        })
      }
    } else {
      data <- mimic_icu_cohort %>%
        select(input$variable)
      output$cohort_plot <- renderPlot({
        data %>%
          ggplot(aes_string(y = input$variable)) +
          geom_bar() +
          theme_minimal()
      })
    }
  })
  
  # second tab
  observeEvent(input$lookup, {
    sid <- input$patient_id
    
    # Load your data
    sid_info <- tbl(con_bq, "patients") %>%
      filter(subject_id == sid) %>%
      collect()
    sid_adt <- tbl(con_bq, "transfers") %>%
      filter(subject_id == sid) %>%
      collect()
    sid_adm <- tbl(con_bq, "admissions") %>%
      filter(subject_id == sid) %>%
      collect()
    sid_lab <- tbl(con_bq, "labevents") %>%
      filter(subject_id == sid) %>%
      collect()
    d_icd_procedures <- tbl(con_bq, "d_icd_procedures") %>%
      collect()
    sid_proc <- tbl(con_bq, "procedures_icd") %>%
      filter(subject_id == sid) %>%
      left_join(d_icd_procedures, by = c("icd_code", "icd_version")) %>%
      collect()
    d_icd_diagnoses <- tbl(con_bq, "d_icd_diagnoses") %>%
      collect()
    sid_diag <- tbl(con_bq, "diagnoses_icd") %>%
      filter(subject_id == sid) %>%
      left_join(d_icd_diagnoses, by = c("icd_code", "icd_version")) %>%
      collect()
    
    # Plotting
    output$adt_icu <- renderPlot({
      ggplot() +
        geom_segment(
          data = sid_adt %>%
            filter(eventtype != "discharge"), 
          aes(x = intime, xend = outtime, y = "ADT", yend = "ADT", color = careunit, linewidth = str_detect(careunit, "(ICU|CCU)"))
        ) +
        geom_point(data = sid_lab %>% distinct(charttime, .keep_all = TRUE), aes(x = charttime, y = "Lab"), shape = '+', size = 5) +
        geom_jitter(data = sid_proc, aes(x = chartdate + hours(12), y = "Procedure", shape = str_sub(long_title, 1, 25)), size = 3, height = 0) +
        labs(
          title = paste(
            "Patient", sid, ",",
            sid_info$gender, ",",
            sid_info$anchor_age + year(sid_adm$admittime[1]) - sid_info$anchor_year, 
            "years old,",
            str_to_lower(sid_adm$race[1])
          ),
          subtitle = paste(str_to_lower(sid_diag$long_title[1:3]), collapse = "\n"),
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
  })
}


# Create Shiny app ----
shinyApp(ui, server)
