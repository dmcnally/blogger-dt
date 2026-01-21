class CommentsController < ApplicationController
  before_action :set_parent_recording
  before_action :set_comment_recording, only: [ :destroy ]

  def create
    @comment_recording = @parent_recording.children.build(
      recordable: Comment.new(comment_params)
    )

    if @comment_recording.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @parent_recording, notice: "Comment was successfully added." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("comment_form", partial: "comments/form", locals: { parent_recording: @parent_recording, comment: @comment_recording.recordable }) }
        format.html { redirect_to @parent_recording, alert: "Comment could not be added." }
      end
    end
  end

  def destroy
    @comment_recording.discard!
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @parent_recording, notice: "Comment was successfully deleted.", status: :see_other }
    end
  end

  private

  def set_parent_recording
    @parent_recording = Recording.find(params[:recording_id])
    unless @parent_recording.recordable.commentable?
      redirect_to @parent_recording, alert: "Comments are not allowed."
    end
  end

  def set_comment_recording
    @comment_recording = @parent_recording.children.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
