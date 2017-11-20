module Placeholder
   extend ActiveSupport::Concern
   
   def self.image_generator(height,weight)
       "http://placehold.it/#{height}x#{weight}"
   end
end