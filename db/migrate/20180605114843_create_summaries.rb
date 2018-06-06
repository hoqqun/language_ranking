class CreateSummaries < ActiveRecord::Migration[5.2]
  def change
    create_table :summaries do |t|
      t.string :language
      t.integer :size

      t.timestamps
    end
  end
end
