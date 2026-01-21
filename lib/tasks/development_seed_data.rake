# frozen_string_literal: true

namespace :development do
  namespace :db do
    desc "Seed development data"
    task seed: :environment do
      # No development seeds
    end
  end
end
