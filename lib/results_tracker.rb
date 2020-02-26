require_relative 'data_tracker'

class ResultsTracker < DataTracker

  def total_goals_per_games(games)
    total_goals = games.values.sum { |game| game.total_goals }.to_f
  end

  def coaches_with_team_id(games)
    gamesteams = gameteams_matching_games(games)
    coaches = {}
    gamesteams.each_value do |gameteam|
      gameteam.each_value do |team|
        coaches[team.head_coach] = [] if !coaches.has_key?(team.head_coach)
        coaches[team.head_coach] << team.result
      end
    end
    coaches
  end

  def gameteams_matching_games(games)
    GameTeam.all.select do |game_id, gameteam|
      games.keys.include?(game_id)
    end
  end

  def games_played_by_team(team)
    Game.all.values.select do |game|
      game.home_team_id == team.team_id || game.away_team_id == team.team_id
    end
  end

  def win_percentage_by_season(season, team_id, type)
      team_games = find_games(season, type).select do |game_id, game_data|
        game_data.home_team_id == team_id || game_data.away_team_id == team_id
      end
      wins = 0
      team_games.each_value do |game_data|
        if team_id == game_data.home_team_id
          wins += 1 if game_data.home_goals > game_data.away_goals
        elsif team_id == game_data.away_team_id
          wins += 1 if game_data.away_goals > game_data.home_goals
        end
      end
      if team_games.count > 0
        percentage = wins.to_f/team_games.count
        percentage.round(3)
      elsif team_games.count == 0
        percentage = 0
      end
  end

  def find_regular_season_teams(season)
    teams = []
    find_games(season, "Regular Season").select do |game_id, game_object|
        teams << game_object.home_team_id
        teams << game_object.away_team_id
    end
    teams = teams.uniq
  end

  def find_post_season_teams(season)
    teams = []
    find_games(season, "Postseason").select do |game_id, game_object|
      teams << game_object.home_team_id
      teams << game_object.away_team_id
    end
    teams = teams.uniq
  end

  def find_eligible_teams(season)
    eligible_teams = []
    find_regular_season_teams(season).each do |team_id|
      eligible_teams << team_id
    find_post_season_teams(season).each do |team_id|
      eligible_teams << team_id
      end
    end
    eligible_teams = eligible_teams.uniq
  end

  def find_games(season, type)
    Game.all.select do |game_id, game_data|
      game_data.season == season && game_data.type == type
    end
  end
end
