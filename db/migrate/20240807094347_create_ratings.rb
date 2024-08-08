class CreateRatings < ActiveRecord::Migration[7.0]
  def change
    create_table :ratings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :field, null: false, foreign_key: true
      t.integer :comment_id
      t.integer :rating

      t.timestamps
    end
  end
end
