class AddNotesToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :notes, :text, after: :description
  end
end
