class CreateRepositories < ActiveRecord::Migration[5.2]
  def change
    create_table :repositories do |t|
      t.integer :repo_id
      t.string :owner
      t.string :url

      t.timestamps
    end
  end
end
