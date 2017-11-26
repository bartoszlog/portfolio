class Blog < ActiveRecord::Base
    validates_presence_of :body, :title
    extend FriendlyId
    friendly_id :title, use: :slugged
    enum status: {draft: 0, published: 1}
    belongs_to :topic
end
