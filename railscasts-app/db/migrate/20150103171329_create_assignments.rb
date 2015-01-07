class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :episode_id
      t.integer :tag_id
      
      t.timestamps
    end
  end
end
