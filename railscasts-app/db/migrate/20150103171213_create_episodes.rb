class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.integer :number
      t.string :name, limit: 300
      t.string :url, limit: 400
      t.text :description
      t.text :notes
      t.time :duration
      t.integer :file_size
      t.boolean :pro
      t.boolean :revised

      t.timestamps
    end
  end
end
