class PostCleanupJob < ApplicationJob
  queue_as :default

  def perform(post)
    post.destroy if post.present?
  end
end
