class Book < ApplicationRecord
  include CrudmaticRecord
  
  belongs_to :author
  belongs_to :category
  
  validates :title, presence: true
  validates :isbn, presence: true, uniqueness: true, length: { is: 13 }
  validates :publication_year, presence: true, 
            numericality: { greater_than: 1000, less_than_or_equal_to: Date.current.year }
  validates :status, inclusion: { in: %w{available checked_out lost damaged reserved} }
  
  # Crudmatic configuration
  crudmatic :index_attributes, [:title, :author, :category, :publication_year, :status]
  crudmatic :show_attributes, proc { |attrs| attrs - [:author_id, :category_id] + [:author, :category] }
  crudmatic :edit_attributes, [:title, :isbn, :publication_year, :description, :author, :category, :status, :pages]
  crudmatic :bulk_editable_attributes, [:status, :author]
  crudmatic :api_attributes, [:id, :title, :isbn, :publication_year, :description, :pages, :status, :author, :category]
  
  crudmatic :search_attributes, [:title, :isbn, :description]
  crudmatic :filter_attributes, [:status]


  crudmatic :pagination_limit, 5  # Show only 5 books per page for demo purposes
  crudmatic :index_order, { title: :asc }  # Sort books alphabetically by title
  
  # Custom input types and options
  crudmatic :radio, :status, %w{available checked_out lost damaged reserved}
  crudmatic :label, :status, "Current Status"
  crudmatic :label, :isbn, "ISBN (13 digits)"
  crudmatic :label, :publication_year, "Year Published"
  crudmatic :label, :author_id, "Author"
  crudmatic :label, :category_id, "Category"
  
  # Input notes for guidance
  crudmatic :input_note, :isbn, "Enter the 13-digit ISBN without dashes or spaces"
  crudmatic :input_note, :publication_year, "Enter the year the book was first published"
  crudmatic :input_note, :description, "Brief summary or description of the book's content"
  crudmatic :input_note, :pages, "Total number of pages in the book"
  crudmatic :input_note, :status, "Select the current status of this book copy"
  
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
