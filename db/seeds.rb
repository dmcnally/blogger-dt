# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Default Bucket (must come first - recordings and events depend on it)
Current.bucket = Bucket.find_or_create_by!(name: "Default")

# Default Person
if Person.none?
  person_card = PersonCard.create!(first_name: "David", last_name: "McNally")
  recording = Recording.create!(recordable: person_card)
  Person.create!(recording: recording)
end

# Default User
person = Person.first
User.find_or_create_by!(email_address: "dave@makoo.com") do |user|
  user.password = "testing"
  user.person = person
end
