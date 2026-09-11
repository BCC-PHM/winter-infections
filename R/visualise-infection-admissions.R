library(readxl)
library(ggplot2)
library(dplyr)
library(bcctheme)

data <- read_excel("data/winter-infections-2526.xlsx")

infections <- unique(data$infection)

icd_10 <- list(
  "COVID-19" = "U07.1",
  "RSV" = "B97.4",
  "Influenza" = "J9-J11"
)

for (infection_i in infections) {
  plt_i <- ggplot(data = data %>%
           filter(infection == infection_i),
         aes(x = week_number,
             y = influenza_count)) +
    geom_col(fill = bcc_cols("purple")) +
    scale_fill_bcc() +
    labs(title = paste0("Hospital Admissions for ", infection_i),
         subtitle = paste0("Birmingham 2025/26 (ICD-10: ", icd_10[[infection_i]], ")"),
         y = "Number of Admissions",
         x = "Week Number") +
    theme_bcc() +
    scale_y_continuous(expand = c(0,0)) +
    scale_x_continuous(expand = c(0,0))
  
  save_name_i <- paste0(
    "output/", stringr::str_to_lower(infection_i), "-2526.png"
  )
  
  ggsave(save_name_i, plt_i, width = 8, height = 5)
}

