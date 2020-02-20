class Team
  @@teams = {}

  def self.add(team)
    @@teams[team.team_id] = team
  end

  def self.all
    @@teams
  end

  def self.teams=(value)
    @@teams = value
  end

  attr_reader :team_id,
              :franchise_id,
              :team_name,
              :abbreviation,
              :stadium,
              :link

  def initialize(data)
    @team_id = data[:team_id]
    @franchise_id = data[:franchiseid]
    @team_name = data[:teamname]
    @abbreviation = data[:abbreviation]
    @stadium = data[:stadium]
    @link = data[:link]
  end

end
