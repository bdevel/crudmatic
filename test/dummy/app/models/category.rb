class Category < ApplicationRecord
  include CrudableRecord
  
  has_many :books, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  
  # Crudable configuration
  crudable :index_attributes, [:name, :description, :books_count]
  crudable :show_attributes, proc { |attrs| attrs + [{books: [:title, :author, :status]}] }
  crudable :edit_attributes, [:name, :description, :color]
  crudable :search_attributes, [:name, :description]
  crudable :api_attributes, [:id, :name, :description, :color, :books]
  
  # Custom labels and input options
  crudable :label, :color, "Category Color"
  crudable :select_options, :color, %w{red blue green yellow purple orange pink gray}
  crudable :input_note, :color, "Choose a color to help identify this category"
  crudable :input_note, :description, "Brief description of what books belong in this category"
  
  def books_count
    books.count
  end
  
  def to_s
    name
  end
end