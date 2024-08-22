class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.references :rating, null: false, foreign_key: true
      t.string :content
      t.integer :parent_id
      t.boolean :isHidden, default: false

      t.timestamps
    end
  end
end
