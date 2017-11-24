class Portfolio < ActiveRecord::Base
    has_many :technologies
    accepts_nested_attributes_for :technologies,
                                    reject_if: lambda { |attrs| attrs['name'].blank? }
    validates_presence_of :title, :body, :main_image, :thumb_image
    include Placeholder
    scope :rails_portfolio_items, -> { where(subtitle: 'Ruby on rails')}
    scope :java_portfolio_items, -> { where(subtitle: 'Java')}
    
    after_initialize :set_defaults
    
    def self.change_position
      order("position DESC")  
    end
    
    def set_defaults
      self.main_image ||= Placeholder.image_generator(600,400)
      self.thumb_image ||= Placeholder.image_generator(350,250)
    end
end
