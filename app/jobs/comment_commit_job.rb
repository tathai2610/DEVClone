class CommentCommitJob < ApplicationJob
  queue_as :default

  def perform(id, action)
    # Do something later
  end
end
