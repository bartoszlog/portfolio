class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include DeviseList
  include SetSource
  include CurrentUserConcern
  
  before_filter :set_title
  
  def set_title
    @page_title = "My Portfolio"
  end
end
