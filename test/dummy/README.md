# 📚 Library Management System - Crudable Engine Demo

This is a demonstration application showcasing the **Crudable Rails Engine** for automatic CRUD operations.

## 🎯 Purpose

This dummy app demonstrates how to use the Crudable engine **without duplicating any view files**. All CRUD functionality (Create, Read, Update, Delete) is provided entirely by the engine while the app only defines:

- **Models** with Crudable configuration
- **Controllers** that inherit from CrudableController  
- **Routes** and basic layout

## 🏗️ Architecture

### Models with CrudableRecord
```ruby
class Book < ApplicationRecord
  include CrudableRecord
  
  # Configure which attributes appear where
  crudable :index_attributes, [:title, :author, :category, :status]
  crudable :edit_attributes, [:title, :isbn, :author_id, :category_id, :status]
  
  # Custom input types and options
  crudable :radio, :status, %w{available checked_out lost damaged}
  crudable :label, :status, "Current Status"
  crudable :input_note, :isbn, "Enter 13-digit ISBN without dashes"
end
```

### Controllers with CrudableController
```ruby
class BooksController < CrudableController
  self.model_class = Book
  # That's it! All CRUD actions are inherited from the engine
end
```

### No View Duplication
- ❌ No `app/views/crudable/` directory in dummy app
- ✅ All views served directly from engine: `crudable/app/views/crudable/`
- ✅ Engine views automatically handle forms, listings, show pages
- ✅ Custom configuration respected (radio buttons, dropdowns, labels, notes)

## 🚀 Getting Started

### 1. Setup Database
```bash
cd crudable/test/dummy
bundle install
rails db:create
rails db:migrate
rails db:seed
```

### 2. Start Server
```bash
rails server
```

### 3. Explore the App
Visit http://localhost:3000 and explore:

- **Books** - Complex forms with radio buttons, dropdowns, associations
- **Authors** - Text areas, date fields, custom labels  
- **Categories** - Select options, color coding

## 🎨 Features Demonstrated

### Configuration Types
- **Attribute Lists**: `crudable :index_attributes, [:name, :email]`
- **Input Types**: `crudable :radio, :status, %w{active inactive}`  
- **Custom Labels**: `crudable :label, :isbn, "ISBN (13 digits)"`
- **Input Notes**: `crudable :input_note, :email, "Must be valid email"`
- **Select Options**: `crudable :select_options, :color, %w{red blue green}`

### Input Types Supported
- ✅ **Text fields** (string columns)
- ✅ **Text areas** (text columns) 
- ✅ **Number fields** (integer/float columns)
- ✅ **Date fields** (date columns)
- ✅ **Checkboxes** (boolean columns)
- ✅ **Radio buttons** (`crudable :radio`)
- ✅ **Dropdowns** (`crudable :select_options`)
- ✅ **Association selects** (belongs_to relationships)
- ✅ **Checkbox lists** (has_many relationships)

### Association Handling
- **Belongs To**: Author dropdown on Book forms
- **Has Many**: Books listed on Author show pages
- **Custom Association Display**: Configurable attributes for related records

## 📊 Sample Data

The seed file creates:
- **5 Categories**: Fiction, Non-Fiction, Mystery, Science Fiction, Biography
- **5 Authors**: Agatha Christie, Isaac Asimov, Maya Angelou, Walter Isaacson, Harper Lee  
- **10 Books**: Mix of classic and modern titles with various statuses

## 🎯 Key Benefits Demonstrated

1. **Zero View Duplication** - Engine provides all CRUD views
2. **Flexible Configuration** - Customize forms without writing HTML
3. **Rapid Development** - Full CRUD in minutes, not hours
4. **Consistent UI** - Standardized interface across all models
5. **Easy Customization** - Override specific views only when needed

## 🔧 Customization Examples

### Basic Configuration
```ruby
# Show only specific attributes on index page
crudable :index_attributes, [:name, :email, :status]

# Custom form inputs
crudable :radio, :priority, %w{low medium high urgent}
crudable :select_options, :department, %w{sales marketing engineering}
```

### Advanced Configuration  
```ruby
# Dynamic options based on model instance
crudable :dropdown, :city, proc {|model| model.state&.cities || [] }

# Proc-based attribute filtering
crudable :show_attributes, proc {|attrs| attrs + [{comments: [:author, :content]}] }
```

## 🎉 Result

A fully functional CRUD application with:
- Professional-looking forms and listings
- Search functionality  
- Bulk operations
- Input validation and error handling
- Mobile-responsive design
- **Zero custom view code required!**

---

*This demonstrates how the Crudable engine enables rapid development of admin interfaces and CRUD applications while maintaining flexibility for customization.*