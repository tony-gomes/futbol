class DataTracker

  def all_seasons
    all_seasons = []
    Game.all.each_value do |game|
      all_seasons << game.season
    end
    all_seasons.uniq
  end

end
