require_relative "modules/accumulable"
class Team
  include Accumulable
  @@teams = {}

  def self.add(team)
    @@teams[team.team_id] = team
  end

  def self.all
    @@teams
  end

  def self.return_team_name(team_id)
    @@teams.find do |_game_id, team|
      if team.team_id == team_id
        return team.team_name
      end
    end
  end

  def self.performance_ranking(group = nil)
  rankings = Team.all.values.minmax_by do |team|
    games_with_team = Game.games_played_by_team(team)
    if !games_with_team.empty?
      total_score = games_with_team.sum do |game|
      if group == :defense
        game.home_team_id == team.team_id ? game.away_goals : game.home_goals
      else
        game.home_team_id == team.team_id ? game.home_goals : game.away_goals
      end
    end
      total_score.to_f / games_with_team.count
    end
  end
  {highest: rankings.last.team_name, lowest: rankings.first.team_name}
  end

  def self.home_or_away_ranking(field = nil)
    rankings = Team.all.values.minmax_by do |team|
      games = Game.all.values.select do |game|
      if field == :home
        game.home_team_id == team.team_id
      else
        game.away_team_id == team.team_id
      end
    end

      total_score = games.sum do |game|
        field == :home ? game.home_goals : game.away_goals
      end
      total_score.to_f / games.count
    end
    {highest: rankings.last.team_name, lowest: rankings.first.team_name}
  end

  def self.winningest_team
    winningest = Team.all.values.max_by do |team|
      games_with_team = Game.games_played_by_team(team)
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

  def self.find_season_teams(season = nil, type = nil)
    teams = []
    Game.find_games(season, type).select do |game_id, game_object|
        teams << game_object.home_team_id
        teams << game_object.away_team_id
    end
    teams = teams.uniq
  end

  def self.coach_rankings(season)
    coaches = GameTeam.coaches_with_team_id(Game.games_in_a_season(season))
    rankings = coaches.reduce({}) do |acc, coach_results|
      acc[coach_results[0]] = coach_results[1].count("WIN") / coach_results[1].count.to_f
      acc
    end
    rankings
  end

  attr_reader :team_id,
              :franchise_id,
              :team_name,
              :abbreviation,
              :stadium,
              :link,
              :team_info

  def initialize(data)
    @team_id = data[:team_id]
    @franchise_id = data[:franchiseid]
    @team_name = data[:teamname]
    @abbreviation = data[:abbreviation]
    @stadium = data[:stadium]
    @link = data[:link]
    @team_info = build_team_info
  end

  def build_team_info
    team_info = {}
    team_info["team_id"] = @team_id.to_s
    team_info["franchise_id"] = @franchise_id.to_s
    team_info["team_name"] = @team_name
    team_info["abbreviation"] = @abbreviation
    team_info["link"] = @link
    team_info
  end

end
