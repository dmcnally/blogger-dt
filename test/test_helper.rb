ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    setup do
      # Bootstrap a test person - skip event tracking for the initial person creation
      Recording.skip_callback(:create, :after, :track_created)
      person_card = PersonCard.create!(first_name: "Test", last_name: "User")
      recording = Recording.create!(recordable: person_card)
      Current.person = Person.create!(recording: recording)
      Recording.set_callback(:create, :after, :track_created)
    end

    teardown do
      Current.reset
    end
  end
end
