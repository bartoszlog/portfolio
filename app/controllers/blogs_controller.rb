class BlogsController < ApplicationController
  before_action :set_blog, only: [:show, :edit, :update, :destroy, :toggle_status]

  def index
    @blogs = Blog.all
  end

  def show
  end

  def new
    @blog = Blog.new
  end

  def edit
  end


  def create
    @blog = Blog.new(blog_params)
    if @blog.save
      redirect_to @blog
    else
      redirect_to new_blog_path
    end
  end


  def update
    if @blog.update(blog_params)
      redirect_to @blog
    else
      redirect_to blog_path
    end
  end


  def destroy
    @blog.destroy
    respond_to do |format|
      format.html { redirect_to blogs_url, notice: 'Post was successfully destroyed.' }
    end
  end
  
  def toggle_status
    if @blog.draft?
      @blog.published!
    else
      @blog.draft!
    end
    redirect_to blogs_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blog
      @blog = Blog.friendly.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def blog_params
      params.require(:blog).permit(:title, :body)
    end
end
