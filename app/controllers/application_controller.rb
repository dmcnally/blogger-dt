class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_current_person

  private

  def set_current_person
    # TODO: Replace with current_user.person when authentication is added
    Current.person = Person.first
    Current.bucket = Bucket.first
  end
end
