module Bucketable
  extend ActiveSupport::Concern

  included do
    belongs_to :bucket

    before_validation :set_bucket_from_current, on: :create
  end

  private

  def set_bucket_from_current
    return if bucket.present?

    raise "Current.bucket must be set" unless Current.bucket

    self.bucket = Current.bucket
  end
end
