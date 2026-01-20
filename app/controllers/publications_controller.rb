class PublicationsController < ApplicationController
  before_action :set_recording

  # POST /recordings/:recording_id/publication
  def create
    @recording.publish!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @recording }
    end
  end

  # DELETE /recordings/:recording_id/publication
  def destroy
    @recording.unpublish!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @recording }
    end
  end

  private

  def set_recording
    @recording = Recording.find(params[:recording_id])
  end
end
