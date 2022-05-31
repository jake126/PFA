function(input, output, session) {
  
  table_data <- reactive({
    player_data %>%
      filter(player_data$current_value!=0 & 
               player_data$League %in% input$league & 
               player_data$position %in% input$position &
               player_data$Team %in% input$team  &
               player_data$primary_nationality %in% input$nationality) %>% 
      mutate(current_value = round(current_value/1000000,2),
             max_reach = round(max_reach/1000000,2)) %>% 
      select("Player","Team","League","primary_nationality","max_reach","current_value","PFI") %>% 
      rename(Nationality = primary_nationality, "Reach (millions)" = max_reach, "Value (millions)" = current_value)
  })
  # JOB 1: default dropdowns to "all" DONE
  # JOB 2: filter so nationality brings through second nationality PENDING
  
  league_data <- reactive({
    player_data %>%
      filter(player_data$current_value!=0 & 
               player_data$League %in% input$league_agg) %>% 
      mutate(current_value = round(current_value/1000000,2),
             max_reach = round(max_reach/1000000,2)) %>% 
      select("Player","Team","League","primary_nationality","max_reach","current_value","PFI") %>% 
      group_by(League) %>%
      summarise(across(where(is.numeric),mean)) %>% 
      rename("Average Reach (millions)" = max_reach, "Average Value (millions)" = current_value, "Average PFI" = PFI)
    })
  
  league_top <- reactive({
    # top player from each league (name, PFI)
    player_data %>%
      filter(player_data$current_value!=0 &
               player_data$League %in% input$league_agg) %>% 
      mutate(current_value = round(current_value/1000000,2),
             max_reach = round(max_reach/1000000,2)) %>% 
      select("Player","Team","League","max_reach","current_value","PFI") %>% 
      arrange(desc(PFI)) %>% 
      group_by(League) %>%
      filter(row_number()==1) %>% 
      rename("Reach (millions)" = max_reach, "Value (millions)" = current_value)
  })
  
  league_stats <- reactive({
    # completeness (no. and %), merge also with above stats
    player_data %>%
      filter(player_data$League %in% input$league_agg) %>%
      select("League","max_reach","current_value","PFI") %>% 
      group_by(League) %>% 
      summarise(players=n(),no_val=sum(current_value==0),no_social=sum(max_reach==0),total_missing=sum(current_value==0 | max_reach==0)) %>%
      mutate(no_defined=round(100*(players-total_missing)/players),2) %>%
      select("League","players","no_val","no_social","no_defined") %>%
      rename("Number of Players" = players, "No Transfer Value" = no_val,"No Social Media"=no_social,"% with PFI defined"=no_defined)
  })
  
  ####### TEAM DATA ######
  team_data <- reactive({
    player_data %>%
      filter(player_data$current_value!=0 & 
               player_data$Team %in% input$team_tm & 
               player_data$League %in% input$league_tm) %>% 
      mutate(current_value = round(current_value/1000000,2),
             max_reach = round(max_reach/1000000,2)) %>% 
      select("Player","Team","League","primary_nationality","max_reach","current_value","PFI") %>% 
      group_by(Team) %>%
      summarise(across(where(is.numeric),mean)) %>% 
      rename("Average Reach (millions)" = max_reach, "Average Value (millions)" = current_value, "Average PFI" = PFI)
  })
  
  team_top <- reactive({
    # top player from each team (name, PFI)
    player_data %>%
      filter(player_data$current_value!=0 &
               player_data$Team %in% input$team_tm & 
               player_data$League %in% input$league_tm) %>% 
      mutate(current_value = round(current_value/1000000,2),
             max_reach = round(max_reach/1000000,2)) %>% 
      select("Player","Team","max_reach","current_value","PFI") %>% 
      arrange(desc(PFI)) %>% 
      group_by(Team) %>%
      filter(row_number()==1) %>% 
      rename("Reach (millions)" = max_reach, "Value (millions)" = current_value)
  })
  
  team_stats <- reactive({
    # completeness (no. and %), merge also with above stats
    player_data %>%
      filter(player_data$Team %in% input$team_tm & 
               player_data$League %in% input$league_tm) %>%
      select("Team","max_reach","current_value","PFI") %>% 
      group_by(Team) %>% 
      summarise(players=n(),no_val=sum(current_value==0),no_social=sum(max_reach==0),total_missing=sum(current_value==0 | max_reach==0)) %>%
      mutate(no_defined=round(100*(players-total_missing)/players),2) %>%
      select("Team","players","no_val","no_social","no_defined") %>%
      rename("Number of Players" = players, "No Transfer Value" = no_val,"No Social Media"=no_social,"% with PFI defined"=no_defined)
  })
  
  
  output$players_table = renderDataTable({
    validate(
      need(dim(table_data())[1]>=1, "Sorry, no players found. Please change the input filters."
      )
    )
    datatable(table_data(),rownames=FALSE) %>%
      formatCurrency("Value (millions)", '\U00A3') %>% 
      formatStyle("PFI",background = styleColorBar(range(table_data()$PFI),'lightblue'))
  })
  
  output$league_player_table = renderDataTable({
    validate(
      need(dim(league_top())[1]>=1, "Please select a league(s) to generate a comparison table."
      )
    )
    datatable(league_top(),caption = "Top PFI Player in each Selected League",rownames=FALSE) %>%
      formatCurrency("Value (millions)", '\U00A3') %>% 
      formatStyle("PFI",background = styleColorBar(range(league_top()$PFI),'lightblue'))
  })
  
  output$league_stats_table = renderDataTable({
    validate(
      need(dim(league_stats())[1]>=1, "Please select a league(s) to generate a comparison table."
      )
    )
    datatable(league_stats(),caption = "PFI Popularity for each Selected League",rownames=FALSE) %>%
      formatStyle("% with PFI defined",background = styleColorBar(range(league_stats()$`% with PFI defined`),'lightblue'))
  })

  ##### TEAMS DATA
  
  output$team_player_table = renderDataTable({
    validate(
      need(dim(team_top())[1]>=1, "Please select a team(s) to generate a comparison table."
      )
    )
    datatable(team_top(),caption = "Top PFI Player in each Selected Team",rownames=FALSE) %>%
      formatCurrency("Value (millions)", '\U00A3') %>% 
      formatStyle("PFI",background = styleColorBar(range(team_top()$PFI),'lightblue'))
  })
  
  output$team_stats_table = renderDataTable({
    validate(
      need(dim(team_stats())[1]>=1, "Please select a team(s) to generate a comparison table."
      )
    )
    datatable(team_stats(),caption = "PFI Popularity for each Selected Team",rownames=FALSE) %>%
      formatStyle("% with PFI defined",background = styleColorBar(range(team_stats()$`% with PFI defined`),'lightblue'))
  })
  
  
    
  # second tab of graphs for top PFI and stats per team/league
  # for all chosen leagues, show top PFI player (with icon? Later, would be nice to colour though)
  # and a graph of average value + reach per team
  # if one league chosen (new tab?) want to show the same data but by teams
  # TO DO add info on how many have PFI defined in teams and leagues? Once visual works
  
  # filter the data for a new dataframe (data_league), plot the new dataframe, add ranking table and 
  # summary stats?
  # repeat for data_team
  
  # want to plot league_data here
  
  # format secondary axis
  ay <- list(
    overlaying = "y",
    side = "right",
    title = "Average Reach/Value (million people/pound spent)")
  
  output$plot_league <- renderPlotly({

    validate(
      need(dim(league_data())[1]>=1, "Please select a league(s) to generate comparison plots."
      )
      )

    plot_ly() %>% 
      add_bars(x = ~league_data()$League, y = ~league_data()$`Average PFI`, name = 'Average PFI (LHS)', 
               marker = list(color = 'rgb(49,130,189)'), offsetgroup = 1) %>%
      add_bars(data, x = ~league_data()$League, y = ~league_data()$`Average Reach (millions)`, name = 'Average Reach (millions, RHS)', 
               marker = list(color = 'rgb(82,64,124)'), yaxis = "y2", offsetgroup = 2) %>%
      add_bars(data, x = ~league_data()$League, y = ~league_data()$`Average Value (millions)`, name = 'Average Value (millions, RHS)', 
               marker = list(color = 'rgb(204,204,204)'), yaxis = "y2", offsetgroup = 3) %>%
      layout(title = "<b>Average PFI Across Selected Leagues</b>",
             yaxis2 = ay,
             xaxis = list(title = "League", tickangle = -45),
             yaxis = list(title = "PFI (followers/1000)"),
             margin = list(b = 100),
             barmode = 'group',
             legend = list(x = 1.1, y = 1))
  })
  
  output$plot_team <- renderPlotly({
    
    validate(
      need(dim(team_data())[1]>=1, "Please select a team(s) to generate comparison plots."
      )
    )
    
    plot_ly() %>% 
      add_bars(x = ~team_data()$Team, y = ~team_data()$`Average PFI`, name = 'Average PFI (LHS)', 
               marker = list(color = 'rgb(49,130,189)'), offsetgroup = 1) %>%
      add_bars(data, x = ~team_data()$Team, y = ~team_data()$`Average Reach (millions)`, name = 'Average Reach (millions, RHS)', 
               marker = list(color = 'rgb(82,64,124)'), yaxis = "y2", offsetgroup = 2) %>%
      add_bars(data, x = ~team_data()$Team, y = ~team_data()$`Average Value (millions)`, name = 'Average Value (millions, RHS)', 
               marker = list(color = 'rgb(204,204,204)'), yaxis = "y2", offsetgroup = 3) %>%
      layout(title = "<b>Average PFI Across Selected Teams</b>",
             yaxis2 = ay,
             xaxis = list(title = "Team", tickangle = -45),
             yaxis = list(title = "PFI (followers/1000)"),
             margin = list(b = 100),
             barmode = 'group',
             legend = list(x = 1.1, y = 1))
  })

  
}