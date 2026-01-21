class ArticlesController < ApplicationController
  before_action :set_recording, only: [ :show, :edit, :update, :destroy ]

  def index
    @recordings = if params[:q].present?
      Recording.kept.search(params[:q], recordable_type: "Article").order(created_at: :desc)
    else
      Recording.kept.articles.order(created_at: :desc)
    end
  end

  def show
  end

  def new
    @article = Article.new
  end

  def create
    @recording = Recording.new(recordable: Article.new(article_params))

    if @recording.save
      redirect_to @recording, notice: "Article was successfully created."
    else
      @article = @recording.recordable
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @article = @recording.recordable
  end

  def update
    # Create new immutable Article, update Recording to point to it
    @recording.recordable = Article.new(article_params)

    if @recording.save
      redirect_to @recording, notice: "Article was successfully updated."
    else
      @article = @recording.recordable
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recording.discard!
    redirect_to articles_path, notice: "Article was successfully deleted.", status: :see_other
  end

  private

  def set_recording
    @recording = Recording.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :body)
  end
end
