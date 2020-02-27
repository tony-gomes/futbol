require "./test/test_helper"
require './lib/stat_tracker'
require "./lib/team"

class TeamTest < Minitest::Test

  def setup
    StatTracker.create_items("./test/fixtures/teams_sample.csv", Team)
    @team1 = Team.new({
                      team_id: 1,
                      franchiseid: 23,
                      teamname: "Atlanta United",
                      abbreviation: "ATL",
                      stadium: "Mercedes-Benz Stadium",
                      link: "/api/v1/teams/1"
                      })
  end

  def test_it_exists
    team = Team.new({})

    assert_instance_of Team, team
  end

  def test_it_has_attributes
    assert_equal 1, @team1.team_id
    assert_equal 23, @team1.franchise_id
    assert_equal "Atlanta United", @team1.team_name
    assert_equal "ATL", @team1.abbreviation
    assert_equal "Mercedes-Benz Stadium", @team1.stadium
    assert_equal "/api/v1/teams/1", @team1.link
  end

  def test_it_can_add_team
    assert_instance_of Hash, Team.all
    assert_equal 10, Team.all.length
    assert_instance_of Team, Team.all[10]
    assert_equal 10, Team.all[10].team_id
    assert_equal 10, Team.all[10].franchise_id
    assert_equal "Team10", Team.all[10].team_name
    assert_equal "TM10", Team.all[10].abbreviation
    assert_equal "Stadium10", Team.all[10].stadium
    assert_equal "/api/v1/teams/10", Team.all[10].link
  end

  def test_it_loads_all_teams_from_csv
    assert_equal 1, Team.all[1].team_id
    assert_equal 8, Team.all[8].team_id
  end

end
