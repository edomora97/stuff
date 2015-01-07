class AddSearchIndexToEpisodes < ActiveRecord::Migration
  def up
    execute "create index episode_name on episodes using gin(to_tsvector('english', name))"
    execute "create index episode_description on episodes using gin(to_tsvector('english', description))"
  end

  def down
    execute "drop index episode_name"
    execute "drop index episode_description"
  end
end
