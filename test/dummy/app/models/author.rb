class Author < ApplicationRecord
  include CrudmaticRecord
  
  has_many :books, dependent: :destroy
  
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  
  # Crudmatic configuration
  crudmatic :index_attributes, [:name, :email, :birth_date, :books_count]
  crudmatic :show_attributes, proc { |attrs| attrs + [{books: {actions: true, attributes: [:title, :isbn, :status]}}] }
  crudmatic :edit_attributes, [:name, :bio, :birth_date, :email, :website]
  crudmatic :search_attributes, [:name, :bio]
  crudmatic :api_attributes, [:id, :name, :bio, :birth_date, :email, :website, :books]
  crudmatic :index_order, { name: :asc }  # Sort authors alphabetically by name
  
  # Custom labels and input notes
  crudmatic :label, :bio, "Author Biography"
  crudmatic :label, :birth_date, "Date of Birth"
  crudmatic :input_note, :email, "Optional - used for contact purposes"
  crudmatic :input_note, :website, "Include http:// or https://"
  crudmatic :input_note, :bio, "Brief description of the author's background"
  
  def books_count
    books.count
  end
  
  def to_s
    name
  end
end
