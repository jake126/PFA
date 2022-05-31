# Used packages
pacotes = c("shiny", "shinydashboard", "shinyWidgets", "shinythemes", "plotly", "shinycssloaders","tidyverse",
            "scales", "knitr", "kableExtra", "ggfortify","dplyr","plotly","FNN","DT")

# Run the following command to verify that the required packages are installed. If some package
# is missing, it will be installed automatically
package.check <- lapply(pacotes, FUN = function(x) {
  if (!require(x, character.only = TRUE)) {
    install.packages(x, dependencies = TRUE)
  }
})

# Define working directory
positional_choices = c("Goalkeeper" = "Goalkeeper", "Left-Back" = "Left-Back",
                       "Centre-Back"="Centre-Back","Right-Back"="Right-Back",
                       "Defensive Midfield"="Defensive Midfield",
                       "Left Midfield"="Left Midfield","Central Midfield"="Central Midfield",
                       "Right Midfield"="Right Midfield","Attacking Midfield"="Attacking Midfield",
                       "Left Winger"="Left Winger","Right Winger"="Right Winger",
                       "Second Striker"="Second Striker","Centre-Forward"="Centre-Forward")


player_data <- rbind(read.csv("EPL_PFI_data_20220110.csv"),read.csv("SPL_PFI_data_20220104.csv"))
player_data$PFI <- round(player_data$PFI,1)
player_data <- player_data %>% select("Player","position","primary_nationality","Team","League","current_value","max_reach","PFI","date_mined_social")

# updated dates
player_data$date_mined_social = strptime(player_data$date_mined_social,format = "%d/%m/%Y %H:%M")
BPL_latest = format(player_data %>% filter(League=="EPL") %>% select(date_mined_social) %>% summarise_all(max),format='%d/%m/%Y')
SPL_latest = format(player_data %>% filter(League=="SPL") %>% select(date_mined_social) %>% summarise_all(max),format='%d/%m/%Y')

