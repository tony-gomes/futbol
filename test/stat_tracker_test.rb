require "./test/test_helper"
require './lib/stat_tracker'
require "./lib/game"
require "./lib/team"
require "./lib/game_team"

class StatTrackerTest < Minitest::Test
  @@locations = {
                games: "./test/fixtures/games_sample.csv",
                game_teams: "./test/fixtures/game_teams_sample.csv",
                teams: "./test/fixtures/teams_sample.csv"
                }

  @@stat_tracker = StatTracker.from_csv(@@locations)

  def test_it_can_find_games
    assert_equal 8, Game.find_games("20122013", "Regular Season").count
    assert_equal 5, Game.find_games("20122013", "Postseason").count
  end

  def test_from_csv_returns_new_instance
    assert_instance_of StatTracker, @@stat_tracker
  end

  def test_it_can_create_items
    assert_equal false, Game.all.empty?
    assert_equal false, GameTeam.all.empty?
    assert_equal false, Team.all.empty?
  end

  def test_it_finds_regular_season_teams
    assert_equal 10, Team.find_season_teams("20132014", "Regular Season").count
    assert_equal false, Team.find_season_teams("20132014", "Regular Season").include?(26)
    assert_equal true, Team.find_season_teams("20132014", "Regular Season").include?(1)
  end

  def test_it_has_post_season_teams
    assert_equal 8, Team.find_season_teams("20132014", "Postseason").count
  end

  def test_it_can_find_eligible_teams
    assert_equal true, @@stat_tracker.find_eligible_teams("20132014").include?(1)
    assert_equal false, @@stat_tracker.find_eligible_teams("20132014").include?(23)
  end

  def test_it_can_calculate_regular_season_win_percentage
    assert_equal 1.0, @@stat_tracker.win_percentage_by_season("20132014", 1, "Regular Season")
  end

  def test_it_can_calculate_post_season_win_percentage
    assert_equal 0.6, @@stat_tracker.win_percentage_by_season("20132014", 10, "Postseason")
    assert_equal 0.0, @@stat_tracker.win_percentage_by_season("20132014", 3, "Postseason")
  end

  def test_it_can_calculate_biggest_bust
    assert_equal "Team2", @@stat_tracker.biggest_bust("20122013")
    assert_equal "Team1", @@stat_tracker.biggest_bust("20132014")
  end

  def test_it_can_calculate_biggest_surprise
    assert_equal "Team1", @@stat_tracker.biggest_surprise("20122013")
    assert_equal "Team2", @@stat_tracker.biggest_surprise("20132014")
  end

  def test_from_csv_loads_all_three_files
    assert_equal 25, Game.all.count
    assert_equal 20, GameTeam.all.count
    assert_equal 10, Team.all.count
  end

  def test_it_can_get_team_info_by_team_id
    expected = {
                "team_id"=>"1",
                "franchise_id"=>"1",
                "team_name"=>"Team1",
                "abbreviation"=>"TM1",
                "link"=>"/api/v1/teams/1"
              }

    assert_instance_of Hash, @@stat_tracker.team_info("1")
    assert_equal expected, @@stat_tracker.team_info("1")
    assert_equal 5, @@stat_tracker.team_info("1").count
    assert_equal 5, @@stat_tracker.team_info("5").count
  end

  def test_it_can_get_best_season
    assert_equal "20132014", @@stat_tracker.best_season("3")
    assert_equal "20122013", @@stat_tracker.best_season("1")
  end

  def test_it_can_get_worst_season
    assert_equal "20122013", @@stat_tracker.worst_season("3")
    assert_equal "20122013", @@stat_tracker.worst_season("5")
    assert_equal "20132014", @@stat_tracker.worst_season("6")
  end

  def test_it_can_get_average_win_percentage_by_team_id
    assert_equal 0.5, @@stat_tracker.average_win_percentage("1")
    assert_equal 1.0, @@stat_tracker.average_win_percentage("4")
  end

  def test_it_can_get_most_goals_scored_by_team_id
    assert_equal 2, @@stat_tracker.most_goals_scored("3")
    assert_equal 5, @@stat_tracker.most_goals_scored("6")
  end

  def test_it_can_get_fewest_goals_scored
    assert_equal 0, @@stat_tracker.fewest_goals_scored("10")
    assert_equal 0, @@stat_tracker.fewest_goals_scored("1")
  end

  def test_it_can_get_biggest_team_blowout
    assert_equal 6, @@stat_tracker.biggest_team_blowout("1")
    assert_equal 2, @@stat_tracker.biggest_team_blowout("10")
  end

  def test_it_can_get_worst_loss
    assert_equal 1, @@stat_tracker.worst_loss("3")
    assert_equal 6, @@stat_tracker.worst_loss("1")
  end

  def test_it_can_get_all_game_teams_by_team_id_in_array
    assert_instance_of Array, GameTeam.all_game_teams_by_team_id("3")
    assert_equal 4, GameTeam.all_game_teams_by_team_id("3").length

    assert_instance_of Array, GameTeam.all_game_teams_by_team_id("10")
    assert_equal 6, GameTeam.all_game_teams_by_team_id("10").length
  end

  def test_it_can_get_all_games_by_team_id_in_array
    assert_instance_of Array, Game.all_games_by_team_id("3")
    assert_equal 4, Game.all_games_by_team_id("3").length

    assert_instance_of Array, Game.all_games_by_team_id("10")
    assert_equal 11, Game.all_games_by_team_id("10").length
  end

  def test_it_can_get_total_results_by_team_id
    assert_instance_of Array, @@stat_tracker.total_results_by_team_id("3")
    assert_equal 4, @@stat_tracker.total_results_by_team_id("3").length

    assert_instance_of Array, @@stat_tracker.total_results_by_team_id("5")
    assert_equal 4, @@stat_tracker.total_results_by_team_id("5").length
  end

  def test_it_can_get_all_goals_scored_by_team_id
    assert_instance_of Array, @@stat_tracker.all_goals_scored_by_team_id("1")
    assert_equal 4, @@stat_tracker.all_goals_scored_by_team_id("2").length
    assert_equal 2, @@stat_tracker.all_goals_scored_by_team_id("3").first
  end

  def test_it_can_get_score_differences_by_team_id
    assert_equal 4, @@stat_tracker.score_differences_by_team_id("1").length
    assert_equal (-1), @@stat_tracker.score_differences_by_team_id("1").first

    assert_equal 4, @@stat_tracker.score_differences_by_team_id("2").length
    assert_equal (1), @@stat_tracker.score_differences_by_team_id("2").first
  end

  def test_it_can_get_team_name
    assert_equal "Team1", @@stat_tracker.get_team_name("1")
    assert_equal "Team10", @@stat_tracker.get_team_name("10")
  end

  def test_it_can_get_win_percentage_by_season
    expected = {"20122013"=>0.0, "20132014"=>0.25}

    assert_instance_of Hash, @@stat_tracker.win_percentage_by_season_by_team_id("3")
    assert_equal expected, @@stat_tracker.win_percentage_by_season_by_team_id("3")
  end

  def test_it_can_calc_win_percentage
    games = [
              Game.new({home_team_id: 1, home_goals: 5, away_team_id: 2, away_goals: 1}),
              Game.new({home_team_id: 2, home_goals: 20, away_team_id: 1, away_goals: 5})
            ]
    team = Team.new({team_id: 1, teamname: "taco terrors"})

    @@stat_tracker.win_percentage(games, team)
  end

  def test_it_knows_how_many_teams_there_are
    assert_equal 10, @@stat_tracker.count_of_teams
  end

  def test_it_knows_best_offense
    assert_equal "Team1", @@stat_tracker.best_offense
  end

  def test_it_knows_worst_offense
    assert_equal "Team8", @@stat_tracker.worst_offense
  end

  def test_it_knows_best_defense
    assert_equal "Team3", @@stat_tracker.best_defense
  end

  def test_it_knows_worst_defense
    assert_equal "Team10", @@stat_tracker.worst_defense
  end

  def test_it_knows_highest_scoring_visitor
    assert_equal "Team1", @@stat_tracker.highest_scoring_visitor
  end

  def test_it_knows_highest_scoring_home_team
    assert_equal "Team5", @@stat_tracker.highest_scoring_home_team
  end

  def test_it_knows_lowest_scoring_visitor
    assert_equal "Team6", @@stat_tracker.lowest_scoring_visitor
  end

  def test_it_knows_lowest_scoring_home_team
    assert_equal "Team1", @@stat_tracker.lowest_scoring_home_team
  end

  def test_it_knows_winningest_team
    assert_equal "Team6", @@stat_tracker.winningest_team
  end

  def test_it_knows_best_fans
    assert_equal "Team5", @@stat_tracker.best_fans
  end

  def test_it_knows_worst_fans
    assert_equal ["Team9", "Team10"], @@stat_tracker.worst_fans
  end

  def test_it_knows_winningest_coach
  assert_equal "Team4 Coach", @@stat_tracker.winningest_coach("20122013")
  end

  def test_it_knows_worst_coach
  assert_equal "Team3 Coach", @@stat_tracker.worst_coach("20122013")
  end

  def test_sort_module
    assert_equal [3, 4, 5, 7, 8], Game.find_all_scores
  end

  def test_highest_total_score
    assert_equal 8, @@stat_tracker.highest_total_score
  end

  def test_lowest_total_score
    assert_equal 3, @@stat_tracker.lowest_total_score
  end

  def test_biggest_blowout
    assert_equal 6, @@stat_tracker.biggest_blowout
  end

  def test_percentage_home_wins
    assert_equal 0.56, @@stat_tracker.percentage_home_wins
  end

  def test_percentage_away_wins
    assert_equal 0.36, @@stat_tracker.percentage_visitor_wins
  end

  def test_percentage_ties
    assert_equal 0.08, @@stat_tracker.percentage_ties
  end

  def test_count_of_games_by_season
    expected = {"20122013"=>13, "20132014"=>12}

    assert_equal expected, @@stat_tracker.count_of_games_by_season
  end

  def test_average_goals_per_game
    assert_equal 4.68, @@stat_tracker.average_goals_per_game
  end

  def test_average_goals_by_season
    expected = {"20122013"=>5.0, "20132014"=>4.33}

    assert_equal expected, @@stat_tracker.average_goals_by_season
  end

  def test_return_team_name
    tackles = mock("tackles")
    tackles.stubs(:accumulator).returns({3 => 10, 10 => 1})

    assert_equal "Team3", @@stat_tracker.return_team_name(tackles.accumulator)
  end

 def test_most_tackles
   game = Game.all.values.first

   assert_equal "Team2", @@stat_tracker.most_tackles(game.season)
 end

  def test_fewest_tackles
    game = Game.all.values.first

    assert_equal "Team7", @@stat_tracker.fewest_tackles(game.season)
  end

  def test_games_in_season
    game = Game.all.values.first

    assert_equal 13, Game.games_in_a_season(game.season).length
  end

  def test_most_accurate_team
    game = Game.all.values.first

    assert_equal "Team1", @@stat_tracker.most_accurate_team(game.season)
  end

  def test_least_accurate_team
    game = Game.all.values.first

    assert_equal "Team9", @@stat_tracker.least_accurate_team(game.season)
  end

  def test_all_seasons
    assert_equal ["20122013", "20132014"], Game.all_seasons
  end

  def test_it_can_get_win_percentage_against_opponent
    assert_equal 1.0, @@stat_tracker.win_percentage_against_opponent("1", "2")
  end

  def test_it_can_get_all_team_average_wins_by_opponent
    assert_equal 1.0, @@stat_tracker.all_team_average_wins_by_opponent("2")[1]
    assert_equal 0.5, @@stat_tracker.all_team_average_wins_by_opponent("7")[8]
  end

  def test_it_can_get_favorite_opponent
    assert_equal "Team4", @@stat_tracker.favorite_opponent("3")
    assert_equal "Team5", @@stat_tracker.favorite_opponent("6")
  end

  def test_it_can_get_rival
    assert_equal "Team4", @@stat_tracker.rival("3")
    assert_equal "Team5", @@stat_tracker.rival("6")
    assert_equal "Team5", @@stat_tracker.rival("10")
  end
end
