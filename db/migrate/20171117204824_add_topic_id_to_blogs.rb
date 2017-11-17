class AddTopicIdToBlogs < ActiveRecord::Migration
  def change
    add_column :blogs, :topic_id, :integer
  end
end
