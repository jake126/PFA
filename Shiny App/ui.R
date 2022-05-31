navbarPage("Player Folk Index",
           tabPanel("PFI Players",fluidPage(theme = shinytheme("flatly")),
                    tags$head(
                      tags$style(HTML(".shiny-output-error-validation{color: red;}"))),
                    pageWithSidebar(
                      headerPanel('Apply filters'),
                      sidebarPanel(width = 4,
                                   pickerInput("league","League:", 
                                               choices = sort(unique(player_data$League)), 
                                               selected = unique(player_data$League),
                                               options = list(`actions-box` = TRUE),multiple = T),
                                   pickerInput("team","Team:", 
                                               choices = sort(unique(player_data$Team)), 
                                               selected = unique(player_data$Team),
                                               options = list(`actions-box` = TRUE),multiple = T),
                                   pickerInput("nationality","Nationality:", 
                                               choices = sort(unique(player_data$primary_nationality)), 
                                               selected = unique(player_data$primary_nationality),
                                               options = list(`actions-box` = TRUE),multiple = T),
                                   checkboxGroupInput(inputId = "position",
                                                      label = 'Position:', choices = positional_choices, 
                                                      selected = positional_choices,inline=TRUE),
                                   submitButton("Update filters")
                      ),
                      mainPanel(
                        #column(8, plotlyOutput("plot1", width = 800, height=700)
                        column(8,DT::dataTableOutput('players_table')
                        )
                      )
                    )),
           tabPanel("League Comparisons",fluidPage(theme = shinytheme("flatly")),
                    tags$head(
                      tags$style(HTML(".shiny-output-error-validation{color: red;}"))),
                    pageWithSidebar(
                      headerPanel('Apply filters'),
                      # filter teams in a certain league
                      sidebarPanel(width = 4,
                                  pickerInput("league_agg","League:", 
                                              choices = sort(unique(player_data$League)), 
                                              selected = unique(player_data$League),
                                              options = list(`actions-box` = TRUE),multiple = T),
                                  submitButton("Update filters")
                     ),
                      mainPanel(
                        column(8, plotlyOutput("plot_league", width = 800, height=700)),
                        #hr(), 
                        #p("Top PFI Player from Selected Leagues:"),
                        column(8,DT::dataTableOutput('league_player_table')),
                        #hr(), 
                        #p("League-wide stats:"),
                        column(8,DT::dataTableOutput('league_stats_table')
                        )
                      )
                    )),
           tabPanel("Team Comparisons",fluidPage(theme = shinytheme("flatly")),
                    tags$head(
                      tags$style(HTML(".shiny-output-error-validation{color: red;}"))),
                    pageWithSidebar(
                      headerPanel('Apply filters'),
                      # filter teams in a certain league
                      sidebarPanel(width = 4,
                                   pickerInput("league_tm","League:",
                                               choices = sort(unique(player_data$League)),
                                               selected = unique(player_data$League),
                                               options = list(`actions-box` = TRUE),multiple = T),
                                   pickerInput("team_tm","Team:",
                                               choices = sort(unique(player_data$Team)),
                                               selected = unique(player_data$Team),
                                               options = list(`actions-box` = TRUE),multiple = T),
                                   submitButton("Update filters")
                      ),
                      mainPanel(
                        column(8, plotlyOutput("plot_team", width = 800, height=700)),
                        column(8,DT::dataTableOutput('team_player_table')),
                        column(8,DT::dataTableOutput('team_stats_table')
                        )
                      )
                    )),
           tabPanel("About",
                    # help at https://shiny.rstudio.com/tutorial/written-tutorial/lesson2/
                    p("About the Player Folk Index",style = "font-size:25px"),
p("The Player Folk Index (PFI) is a new measure to track the social impact of football players and teams. 
PFI measures the popularity of players indexed against their on-field ability, as measured by transfer value. Players with a high PFI are more popular 
with fans than their on-field ability would indicate, thus cultivating a 'folk' status. Players with a low PFI are potentially missing out on a higher 
social media presence. Two key uses of the tool are to track clubs' (and leagues') online footprint, as well as giving teams' scouts more information 
                      when considering whether to bring in a new player."),
                    p("PFI is calculated as the number of fans brought to the club (in thousands) per transfer pound spent: a player with 1000 social media followers and a transfer
                       value of 1 would have a PFI score of 1. 'Social media followers' and 'transfer value' are defined as follows:"),
                    p(" - Social media followers: the higher online presence across Instagram and Twitter, weighted for recency and frequency of posts. Players without a presence on either site are allocated a following of 0"),
p(" - Transfer value: latest estimated transfer fee, as tracked on ",
  a("transfermarkt.com", href="https://www.transfermarkt.co.uk/"),". Players without transfer values are omitted from tables to avoid infinite PFI values. Squad rosters, player nationalities, and player positions are defined by Transfermarkt."),
p("For more information on the methodology and potential use cases for the tool, visit ",
a("our GitHub repo", href="https://github.com/jake126/PFA"),"."),
                    hr(), 
                    p("Currently available leagues:",style = "font-size:25px"),
                    p(paste0("SPL: Scottish Premier League, Scotland (last updated: ",SPL_latest,")"),style = "font-size:15px;color: blue"),
                    p(paste0("BPL: Barclays Premier League, England (last updated: ",BPL_latest,")"),style = "font-size:15px;color: blue")
           ), 

           tabPanel("Developers",
                    p(a("Jake Barrett", href="http://twitter.com", target="_blank"),style = "font-size:25px"),
                    p("e-mail: jbarrett2601@gmail.com",style = "font-size:20px"),
                    p(a("Ellen Frank Delgado", href="http://twitter.com", target="_blank"),style = "font-size:25px"),
                    p("email: E.M.Frank-Delgado@sms.ed.ac.uk",style = "font-size:20px")
           )
)
