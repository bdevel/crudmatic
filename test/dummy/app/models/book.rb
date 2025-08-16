class Book < ApplicationRecord
  include CrudableRecord
  
  belongs_to :author
  belongs_to :category
  
  validates :title, presence: true
  validates :isbn, presence: true, uniqueness: true, length: { is: 13 }
  validates :publication_year, presence: true, 
            numericality: { greater_than: 1000, less_than_or_equal_to: Date.current.year }
  validates :status, inclusion: { in: %w{available checked_out lost damaged reserved} }
  
  # Crudable configuration
  crudable :index_attributes, [:title, :author, :category, :publication_year, :status]
  crudable :show_attributes, proc { |attrs| attrs - [:author_id, :category_id] + [:author, :category] }
  crudable :edit_attributes, [:title, :isbn, :publication_year, :description, :author_id, :category_id, :status, :pages]
  crudable :search_attributes, [:title, :isbn, :description]
  crudable :api_attributes, [:id, :title, :isbn, :publication_year, :description, :pages, :status, :author, :category]
  crudable :pagination_limit, 5  # Show only 5 books per page for demo purposes
  crudable :index_order, { title: :asc }  # Sort books alphabetically by title
  
  # Custom input types and options
  crudable :radio, :status, %w{available checked_out lost damaged reserved}
  crudable :label, :status, "Current Status"
  crudable :label, :isbn, "ISBN (13 digits)"
  crudable :label, :publication_year, "Year Published"
  crudable :label, :author_id, "Author"
  crudable :label, :category_id, "Category"
  
  # Input notes for guidance
  crudable :input_note, :isbn, "Enter the 13-digit ISBN without dashes or spaces"
  crudable :input_note, :publication_year, "Enter the year the book was first published"
  crudable :input_note, :description, "Brief summary or description of the book's content"
  crudable :input_note, :pages, "Total number of pages in the book"
  crudable :input_note, :status, "Select the current status of this book copy"
  
  def to_s
    title
  end
  
  def status_color
    case status
    when 'available' then 'green'
    when 'checked_out' then 'blue'
    when 'reserved' then 'orange'
    when 'lost' then 'red'
    when 'damaged' then 'purple'
    else 'gray'
    end
  end
end
