# Library Management System Seed Data

puts "🌱 Seeding library management system..."

# Clear existing data
Book.destroy_all
Author.destroy_all
Category.destroy_all

# Create Categories
fiction = Category.create!(
  name: "Fiction",
  description: "Imaginative and creative literature including novels, short stories, and novellas",
  color: "blue"
)

non_fiction = Category.create!(
  name: "Non-Fiction", 
  description: "Factual books including biographies, history, science, and self-help",
  color: "green"
)

mystery = Category.create!(
  name: "Mystery",
  description: "Suspenseful stories involving crimes, puzzles, and investigations",
  color: "purple"
)

science_fiction = Category.create!(
  name: "Science Fiction",
  description: "Speculative fiction dealing with futuristic concepts and technology",
  color: "orange"
)

biography = Category.create!(
  name: "Biography",
  description: "Life stories of notable people throughout history",
  color: "red"
)

puts "✅ Created #{Category.count} categories"

# Create Authors
agatha_christie = Author.create!(
  name: "Agatha Christie",
  bio: "British crime novelist, short story writer, and playwright. Known for her detective characters Hercule Poirot and Miss Marple.",
  birth_date: Date.new(1890, 9, 15),
  email: "info@agathachristie.com",
  website: "https://www.agathachristie.com"
)

isaac_asimov = Author.create!(
  name: "Isaac Asimov",
  bio: "American writer and professor of biochemistry. Prolific science fiction author known for the Foundation series and robot stories.",
  birth_date: Date.new(1920, 1, 2),
  email: "contact@asimov.com",
  website: "https://www.asimov.com"
)

maya_angelou = Author.create!(
  name: "Maya Angelou",
  bio: "American poet, memoirist, and civil rights activist. Best known for her series of autobiographies.",
  birth_date: Date.new(1928, 4, 4),
  email: "info@mayaangelou.com"
)

walter_isaacson = Author.create!(
  name: "Walter Isaacson",
  bio: "American writer and journalist. Former CEO of CNN and managing editor of Time magazine.",
  birth_date: Date.new(1952, 5, 20),
  email: "walter@isaacson.com",
  website: "https://www.walterisaacson.com"
)

harper_lee = Author.create!(
  name: "Harper Lee",
  bio: "American novelist widely known for To Kill a Mockingbird, which won the Pulitzer Prize for Fiction in 1961.",
  birth_date: Date.new(1926, 4, 28)
)

puts "✅ Created #{Author.count} authors"

# Create Books
books_data = [
  {
    title: "Murder on the Orient Express",
    isbn: "9780062693662",
    publication_year: 1934,
    description: "A luxurious train ride becomes a thrilling mystery when a passenger is found murdered.",
    pages: 256,
    status: "available",
    author: agatha_christie,
    category: mystery
  },
  {
    title: "The Murder of Roger Ackroyd", 
    isbn: "9780062073563",
    publication_year: 1926,
    description: "Hercule Poirot investigates the murder of a wealthy businessman in a English village.",
    pages: 288,
    status: "checked_out",
    author: agatha_christie,
    category: mystery
  },
  {
    title: "Foundation",
    isbn: "9780553293357",
    publication_year: 1951,
    description: "The first novel in Asimov's Foundation series about the fall of a galactic empire.",
    pages: 244,
    status: "available",
    author: isaac_asimov,
    category: science_fiction
  },
  {
    title: "I, Robot",
    isbn: "9780553294385",
    publication_year: 1950,
    description: "A collection of short stories about robots and the Three Laws of Robotics.",
    pages: 224,
    status: "reserved",
    author: isaac_asimov,
    category: science_fiction
  },
  {
    title: "Foundation and Empire",
    isbn: "9780553293371",
    publication_year: 1952,
    description: "The second book in the Foundation series, continuing the saga of the Foundation.",
    pages: 272,
    status: "available",
    author: isaac_asimov,
    category: science_fiction
  },
  {
    title: "I Know Why the Caged Bird Sings",
    isbn: "9780345514400",
    publication_year: 1969,
    description: "The first in a series of autobiographical works by Maya Angelou.",
    pages: 281,
    status: "available",
    author: maya_angelou,
    category: biography
  },
  {
    title: "Steve Jobs",
    isbn: "9781451648539",
    publication_year: 2011,
    description: "The exclusive biography of Apple co-founder Steve Jobs.",
    pages: 656,
    status: "available",
    author: walter_isaacson,
    category: biography
  },
  {
    title: "Einstein: His Life and Universe",
    isbn: "9780743264747",
    publication_year: 2007,
    description: "A comprehensive biography of Albert Einstein based on newly released personal letters.",
    pages: 675,
    status: "checked_out",
    author: walter_isaacson,
    category: biography
  },
  {
    title: "To Kill a Mockingbird",
    isbn: "9780446310789",
    publication_year: 1960,
    description: "A gripping tale of racial injustice and childhood innocence in the American South.",
    pages: 376,
    status: "available",
    author: harper_lee,
    category: fiction
  },
  {
    title: "Go Set a Watchman",
    isbn: "9780062409850",
    publication_year: 2015,
    description: "Harper Lee's second novel, featuring an adult Scout Finch returning to Alabama.",
    pages: 278,
    status: "damaged",
    author: harper_lee,
    category: fiction
  }
]

books_data.each do |book_attrs|
  Book.create!(book_attrs)
end

puts "✅ Created #{Book.count} books"

# Display summary
puts "\n📚 Library Management System Seeded Successfully!"
puts "="*50
puts "📊 Summary:"
puts "   Authors: #{Author.count}"
puts "   Categories: #{Category.count}" 
puts "   Books: #{Book.count}"
puts "\n📈 Book Status Distribution:"
Book.group(:status).count.each do |status, count|
  puts "   #{status.titleize}: #{count}"
end
puts "\n🎯 Ready to test the Crudable engine!"
puts "   Start the server and visit: http://localhost:3000"