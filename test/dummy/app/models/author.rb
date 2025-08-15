class Author < ApplicationRecord
  include CrudableRecord
  
  has_many :books, dependent: :destroy
  
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  
  # Crudable configuration
  crudable :index_attributes, [:name, :email, :birth_date, :books_count]
  crudable :show_attributes, proc { |attrs| attrs + [{books: [:title, :isbn, :status]}] }
  crudable :edit_attributes, [:name, :bio, :birth_date, :email, :website]
  crudable :search_attributes, [:name, :bio]
  crudable :api_attributes, [:id, :name, :bio, :birth_date, :email, :website, :books]
  crudable :index_order, { name: :asc }  # Sort authors alphabetically by name
  
  # Custom labels and input notes
  crudable :label, :bio, "Author Biography"
  crudable :label, :birth_date, "Date of Birth"
  crudable :input_note, :email, "Optional - used for contact purposes"
  crudable :input_note, :website, "Include http:// or https://"
  crudable :input_note, :bio, "Brief description of the author's background"
  
  def books_count
    books.count
  end
  
  def to_s
    name
  end
end