require 'csv'
require_relative 'game'
require_relative 'game_team'
require_relative 'team'

class StatTracker

  def initialize()
  end

  def self.from_csv(locations)
    StatTracker.create_items(locations[:games], Game)
    StatTracker.create_items(locations[:game_teams], GameTeam)
    StatTracker.create_items(locations[:teams], Team)
    StatTracker.new()
  end

  def self.create_items(file, item_class)
    csv_options = {
                    headers: true,
                    header_converters: :symbol,
                    converters: :all
                  }
      CSV.foreach(file, csv_options) { |row| item_class.add(item_class.new(row.to_hash)) }
  end

  def count_of_teams
    Team.all.count
  end

  def best_offense
    teams = change_data_to_array(Team)
    best_team = teams.max_by do |team|
      games_with_team = games_played_by_team(team)
      if !games_with_team.empty?
        total_score = games_with_team.sum do |game|
          game.home_team_id == team.team_id ? game.home_goals : game.away_goals
        end
        total_score.to_f / games_with_team.count
      end
    end
    best_team.team_name
  end

  def worst_offense
    teams = change_data_to_array(Team)
    worst_team = teams.min_by do |team|
      games_with_team = games_played_by_team(team)
      if !games_with_team.empty?
        total_score = games_with_team.sum do |game|
          game.home_team_id == team.team_id ? game.home_goals : game.away_goals
      end
        total_score.to_f / games_with_team.count
      end
    end
    worst_team.team_name
  end

  def best_defense
    teams = change_data_to_array(Team)
    best_team = teams.min_by do |team|
      games_with_team = games_played_by_team(team)
      if !games_with_team.empty?
        total_score = games_with_team.sum do |game|
          game.home_team_id == team.team_id ? game.away_goals : game.home_goals
      end
        total_score.to_f / games_with_team.count
      end
    end
    best_team.team_name
  end

  def worst_defense
    teams = change_data_to_array(Team)
    worst_team = teams.max_by do |team|
      games_with_team = games_played_by_team(team)
      if !games_with_team.empty?
        total_score = games_with_team.sum do |game|
          game.home_team_id == team.team_id ? game.away_goals : game.home_goals
      end
        total_score.to_f / games_with_team.count
      end
    end
    worst_team.team_name
  end

  def highest_scoring_visitor
    teams = change_data_to_array(Team)
    games = change_data_to_array(Game)
    highest_visitor = teams.max_by do |team|
      games_visiting = games.select { |game| game.away_team_id == team.team_id }
      total_score = games_visiting.sum { |game| game.away_goals }
      total_score.to_f / games_visiting.count
    end
    highest_visitor.team_name
  end

  def lowest_scoring_visitor
    teams = change_data_to_array(Team)
    games = change_data_to_array(Game)
    highest_visitor = teams.min_by do |team|
      games_visiting = games.select { |game| game.away_team_id == team.team_id }
      total_score = games_visiting.sum { |game| game.away_goals }
      total_score.to_f / games_visiting.count
    end
    highest_visitor.team_name
  end

  def highest_scoring_home_team
    teams = change_data_to_array(Team)
    games = change_data_to_array(Game)
    highest_home = teams.max_by do |team|
      games_visiting = games.select { |game| game.home_team_id == team.team_id }
      total_score = games_visiting.sum { |game| game.home_goals }
      total_score.to_f / games_visiting.count
    end
    highest_home.team_name
  end

  def lowest_scoring_home_team
    teams = change_data_to_array(Team)
    games = change_data_to_array(Game)
    lowest_home = teams.min_by do |team|
      games_visiting = games.select { |game| game.home_team_id == team.team_id }
      total_score = games_visiting.sum { |game| game.home_goals }
      total_score.to_f / games_visiting.count
    end
    lowest_home.team_name
  end

  def winningest_team
    teams = change_data_to_array(Team)
    winningest = teams.max_by do |team|
      games_with_team = games_played_by_team(team)
      if !games_with_team.empty?
        games_won = games_with_team.count do |game|
          if game.home_team_id == team.team_id
            game.home_goals > game.away_goals
          else
            game.away_goals > game.home_goals
          end
        end
      end
      games_won.to_f / games_with_team.count
    end
    winningest.team_name
  end

  def best_fans
    teams = change_data_to_array(Team)
    biggest_home_away_diff = teams.max_by do |team|
      games_with_team = games_played_by_team(team)
      if !games_with_team.empty?
        home_games, away_games = games_with_team.partition do |game|
          game.home_team_id == team.team_id
        end
        home_win_percentage = win_percentage(home_games, team)
        away_win_percentage = win_percentage(away_games, team)
        (home_win_percentage - away_win_percentage).abs
      end

    end
    biggest_home_away_diff.team_name
  end

  def worst_fans
    teams = change_data_to_array(Team)
    teams_with_better_away = teams.select do |team|
      games_with_team = games_played_by_team(team)
      home_games, away_games = games_with_team.partition do |game|
        game.home_team_id == team.team_id
      end
      home_win_percentage = win_percentage(home_games, team)
      away_win_percentage = win_percentage(away_games, team)
      away_win_percentage > home_win_percentage
    end
    teams_with_better_away.map { |team| team.team_name }
  end

  def win_percentage(games, team)
    team = team.team_id if team.is_a?(Team)
    total_score = games.sum do |game|
      if game.home_team_id == team
        game.home_goals > game.away_goals ? 1 : 0
      elsif game.away_team_id == team
        game.away_goals > game.home_goals ? 1 : 0
      end
    end
    total_score.to_f / games.count
  end

  def change_data_to_array(data_class)
    data_class.all.values
  end

  def games_played_by_team(team)
    Game.all.values.select do |game|
      game.home_team_id == team.team_id || game.away_team_id == team.team_id
    end
  end

  def winningest_coach(season)
    season = season.to_i
    # Get a list of games in the season
    games = games_in_a_season(season)
    # Get a list of coaches and thier team ids
    coaches = coaches_with_team_id(games)
    # calculate win percentage for each coach and get max
    winner = coaches.max_by do |coach, game_results|
      game_results.count("WIN") / game_results.count.to_f
    end
    winner.first
  end

 def gameteams_matching_games(games)
   GameTeam.all.select do |game_id, gameteam|
     games.keys.include?(game_id)
   end
 end

  def coaches_with_team_id(games)
    # get a list of gameteams in the season
    gamesteams = gameteams_matching_games(games)
    # get list of coaches in the current season
    coaches = {}
    gamesteams.each_value do |gameteam|
      gameteam.each_value do |team|
        coaches[team.head_coach] = [] if !coaches.has_key?(team.head_coach)
        coaches[team.head_coach] << team.result
      end
    end
    coaches
  end

  def games_in_a_season(season)
    Game.all.select do |game_id, game|
      game.season == season
    end
  end

  def worst_coach(season)
    season = season.to_i
    # Get a list of games in the season
    games = games_in_a_season(season)
    # Get a list of coaches and thier team ids
    coaches = coaches_with_team_id(games)
    # calculate win percentage for each coach and get max
    loser = coaches.min_by do |coach, game_results|
      game_results.count("WIN") / game_results.count.to_f
    end
    loser.first
  end

  def highest_total_score
    Game.find_all_scores.max
  end

  def lowest_total_score
    Game.find_all_scores.min
  end

  def biggest_blowout
    Game.find_all_scores("subtract").max
  end

  def percentage_home_wins
    Game.games_outcome_percent("home")
  end

  def percentage_visitor_wins
    Game.games_outcome_percent("away")
  end

  def percentage_ties
    Game.games_outcome_percent("draw")
  end

  def count_of_games_by_season
    Game.all.values.reduce(Hash.new(0)) do |games_by_season, game|
      games_by_season[game.season.to_s] += 1
      games_by_season
    end
  end

  def average_goals_per_game
    total_goals_per_game = []
    Game.all.each_value do |game|
      total_goals_per_game << game.away_goals + game.home_goals.to_f
    end
    (total_goals_per_game.sum / Game.all.length).round(2)
  end

  def total_goals_per_season(season)
    total_goals = 0.0
    Game.all.each_value do |game|
      if game.season == season
        total_goals += (game.away_goals + game.home_goals)
      end
    end
    total_goals
  end

  def average_goals_by_season
    Game.all.each_value.reduce(Hash.new(0)) do |goals_by_season, game|
      goals = total_goals_per_season(game.season)
      games = Game.games_in_a_season(game.season).length

      goals_by_season[game.season.to_s] = (goals / games).round(2)
      goals_by_season
    end
  end

  def return_team_name(acc, condition = "max")
    if condition == "min"
      stat = acc.values.min
    else
      stat = acc.values.max
    end

    team = acc.key(stat)
    Team.all[team].team_name
  end

  def most_tackles(season)
    games = Game.games_in_a_season(season)
    gameteams = GameTeam.season_games(games)

    tackles = Hash.new(0)
    gameteams.each_value do |gameteam|
      gameteam.each_value do |team|
        tackles[team.team_id] += team.tackles
      end
    end
    return_team_name(tackles)
  end

  def fewest_tackles(season)
    games = Game.games_in_a_season(season)
    gameteams = GameTeam.season_games(games)

    tackles = Hash.new(0)
    gameteams.each_value do |gameteam|
      gameteam.each_value do |team|
        tackles[team.team_id] += team.tackles
      end
    end
    return_team_name(tackles, "min")
  end

  def most_accurate_team(season)
    games = Game.games_in_a_season(season)
    gameteams = GameTeam.season_games(games)

    teams = Hash.new
    gameteams.each_value do |gameteam|
      gameteam.each_value do |team|
        teams[team.team_id] = Hash.new(0) if !teams.has_key?(team.team_id)
        teams[team.team_id][:shots] += team.shots
        teams[team.team_id][:goals] += team.goals
      end
    end

    accuracy = teams.transform_values do |team|
      ((team[:goals] / team[:shots].to_f) * 100).round(2)
    end
    return_team_name(accuracy)
  end

  def least_accurate_team(season)
    games = Game.games_in_a_season(season)
    gameteams = GameTeam.season_games(games)

    teams = Hash.new
    gameteams.each_value do |gameteam|
      gameteam.each_value do |team|
        teams[team.team_id] = Hash.new(0) if !teams.has_key?(team.team_id)
        teams[team.team_id][:shots] += team.shots
        teams[team.team_id][:goals] += team.goals
      end
    end

    accuracy = teams.transform_values do |team|
      ((team[:goals] / team[:shots].to_f) * 100).round(2)
    end
    return_team_name(accuracy, "min")
  end

end
