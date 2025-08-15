class CreateAuthors < ActiveRecord::Migration[7.2]
  def change
    create_table :authors do |t|
      t.string :name, null: false
      t.text :bio
      t.date :birth_date
      t.string :email
      t.string :website
      
      t.timestamps
    end
    
    add_index :authors, :name
    add_index :authors, :email
  end
end