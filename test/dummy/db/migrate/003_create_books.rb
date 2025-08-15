class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :isbn, null: false
      t.integer :publication_year, null: false
      t.text :description
      t.integer :pages
      t.string :status, default: 'available'
      t.references :author, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      
      t.timestamps
    end
    
    add_index :books, :isbn, unique: true
    add_index :books, :title
    add_index :books, :status
    add_index :books, :publication_year
  end
end