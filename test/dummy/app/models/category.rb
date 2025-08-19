class Category < ApplicationRecord
  include CrudmaticRecord
  
  has_many :books, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  
  # Crudmatic configuration
  crudmatic :index_attributes, [:name, :description, :active, :books_count]
  crudmatic :show_attributes, proc { |attrs| attrs + [{books: [:title, :author, :status]}] }
  crudmatic :edit_attributes, [:name, :description, :color, :active]
  crudmatic :search_attributes, [:name, :description]
  crudmatic :api_attributes, [:id, :name, :description, :color, :active, :books]
  crudmatic :filter_attributes, [:active]
  
  # Custom labels and input options
  crudmatic :label, :color, "Category Color"
  crudmatic :select_options, :color, %w{red blue green yellow purple orange pink gray}
  crudmatic :input_note, :color, "Choose a color to help identify this category"
  crudmatic :input_note, :description, "Brief description of what books belong in this category"
  
  def books_count
    books.count
  end
  
  def to_s
    name
  end
end