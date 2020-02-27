class GameTeam
  @@game_teams = {}

  def self.add(game_team)
    @@game_teams[game_team.game_id] = {} if !@@game_teams.has_key?(game_team.game_id)
    @@game_teams[game_team.game_id][game_team.team_id] = game_team
  end

  def self.all
    @@game_teams
  end

  def self.season_games(games)
      @@game_teams.select do |game_id, gameteam|
        games.keys.include?(game_id)
      end
  end

  def self.matching_games(games)
    @@game_teams.select do |game_id, gameteam|
      games.keys.include?(game_id)
    end
  end

  def self.coaches_with_team_id(games)
    gamesteams = GameTeam.matching_games(games)
    coaches = {}
    gamesteams.each_value do |gameteam|
      gameteam.each_value do |team|
        coaches[team.head_coach] = [] if !coaches.has_key?(team.head_coach)
        coaches[team.head_coach] << team.result
      end
    end
    coaches
  end

  def self.all_game_teams_by_team_id(team_id)
    team_id = team_id.to_i if team_id.class != Integer
    @@game_teams.reduce([]) do |return_games, game|
      return_games << game.last.fetch(team_id) if game.last.has_key?(team_id)
      return_games
    end
  end

  attr_reader :game_id,
              :team_id,
              :hoa,
              :result,
              :settled_in,
              :head_coach,
              :goals,
              :shots,
              :tackles,
              :pim,
              :power_play_opportunities,
              :power_play_goals,
              :face_off_win_percentage,
              :giveaways,
              :takeaways

  def initialize(data)
    @game_id = data[:game_id]
    @team_id = data[:team_id]
    @hoa = data[:hoa]
    @result = data[:result]
    @settled_in = data[:settled_in]
    @head_coach = data[:head_coach]
    @goals = data[:goals]
    @shots = data[:shots]
    @tackles = data[:tackles]
    @pim = data[:pim]
    @power_play_opportunities = data[:powerplayopportunities]
    @power_play_goals = data[:powerplaygoals]
    @face_off_win_percentage = data[:faceoffwinpercentage]
    @giveaways = data[:giveaways]
    @takeaways = data[:takeaways]
  end

end
