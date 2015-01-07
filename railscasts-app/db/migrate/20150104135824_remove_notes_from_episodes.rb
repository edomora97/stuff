class RemoveNotesFromEpisodes < ActiveRecord::Migration
  def change
    remove_column :episodes, :notes
  end
end
