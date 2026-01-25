ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    setup do
      # Bootstrap bucket and person for tests
      Current.bucket = Bucket.find_or_create_by!(name: "Test")
      person_card = PersonCard.create!(first_name: "Test", last_name: "User")
      recording = Recording.create!(recordable: person_card)
      person = Person.create!(recording: recording)
      user = User.create!(email_address: "test@example.com", password: "password", person: person)
      Current.session = Session.create!(user: user)
    end

    teardown do
      Current.reset
    end
  end
end
