require "./test/test_helper"
require './lib/stat_tracker'
require "./lib/game"
require "./lib/team"
require "./lib/game_team"


class StatTrackerTest < Minitest::Test

#  def setup
#    @locations = {
#                  games: "./test/fixtures/season_games_sample.csv",
#                  game_teams: "./test/fixtures/game_teams_sample.csv",
#                  teams: "./test/fixtures/teams_sample.csv"
#                }
#    @stat_tracker = StatTracker.from_csv(@locations)
#  end

  def teardown
    Game.games = {}
    Team.teams = {}
    GameTeam.game_teams = {}
  end

  def test_it_exists
    @locations = {
                  games: "./test/fixtures/season_games_sample.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_instance_of StatTracker, StatTracker.new
  end

  def test_from_csv_returns_new_instance
    @locations = {
                  games: "./test/fixtures/season_games_sample.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_instance_of StatTracker, @stat_tracker
  end

  def test_it_can_create_items
    @locations = {
                  games: "./test/fixtures/season_games_sample.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)
    StatTracker.create_items("./test/fixtures/teams_sample.csv", Team)

    assert_instance_of Team, Team.all[1]
  end

  def test_from_csv_loads_all_three_files
    @locations = {
                  games: "./test/fixtures/season_games_sample.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_equal 20, Game.all.count
    assert_equal 50, GameTeam.all.count
    assert_equal 32, Team.all.count
  end

  def test_it_can_find_regular_season_games
    @locations = {
                  games: "./test/fixtures/season_games_sample.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_equal 5, @stat_tracker.find_games_in_regular_season(20122013).count
    assert_equal 5, @stat_tracker.find_games_in_regular_season(20142015).count
  end

  def test_it_can_find_post_season_games
    @locations = {
                  games: "./test/fixtures/season_games_sample.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_equal 5, @stat_tracker.find_games_in_post_season(20122013).count
    assert_equal 5, @stat_tracker.find_games_in_post_season(20142015).count
  end

  def test_it_has_regular_season_teams
    @locations = {
                  games: "./test/fixtures/season_games_sample.csv",
                  game_teams: "./data/game_teams.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_equal 9, @stat_tracker.find_regular_season_teams(20142015).count
  end

  def test_it_has_post_season_teams
    @locations = {
                  games: "./test/fixtures/season_games_sample.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_equal 2, @stat_tracker.find_post_season_teams(20142015).count
  end



  def test_it_can_find_bust_eligible_teams
    @locations = {
                  games: "./data/games.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_equal true, @stat_tracker.find_eligible_teams(20142015).include?(14)
    assert_equal true, @stat_tracker.find_eligible_teams(20142015).include?(5)
  #  assert_equal true, @stat_tracker.find_bust_eligible_teams(20132014).include?(23)
  end

  def test_it_can_calculate_regular_season_win_percentage
    @locations = {
                  games: "./test/fixtures/season_games_sample.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_equal 0.667, @stat_tracker.win_percentage(20122013, 6, "Regular Season")
  end

  def test_it_can_calculate_post_season_win_percentage
    @locations = {
                  games: "./test/fixtures/season_games_sample.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_equal 1.0, @stat_tracker.win_percentage(20122013, 6, "Postseason")
    assert_equal 0, @stat_tracker.win_percentage(20122013, 3, "Postseason")
  end

  def test_it_can_calculate_biggest_bust
    @locations = {
                  games: "./data/games.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_equal "Sporting Kansas City", @stat_tracker.biggest_bust(20142015)
#    assert_equal "Montreal Impact", @stat_tracker.biggest_bust(20132014)
  end

  def test_it_can_calculate_biggest_surprise
    @locations = {
                  games: "./data/games.csv",
                  game_teams: "./test/fixtures/game_teams_sample.csv",
                  teams: "./test/fixtures/teams_sample.csv"
                  }
    @stat_tracker = StatTracker.from_csv(@locations)

    assert_equal "Minnesota United FC", @stat_tracker.biggest_surprise(20142015)
    assert_equal "FC Cincinnati", @stat_tracker.biggest_surprise(20132014)
  end

end
