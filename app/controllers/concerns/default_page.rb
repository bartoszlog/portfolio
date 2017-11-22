module DefaultPage
  extend ActiveSupport::Concern
   
  included do
    before_filter :set_page_defaults
  end
  
  def set_page_defaults
    @page_title = "My Portfolio"
  end
end