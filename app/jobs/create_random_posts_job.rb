require 'faker'

class CreateRandomPostsJob < ApplicationJob
  queue_as :default

  def perform
    a = Post.create(title: Faker::Lorem.sentence, body: Faker::Lorem.paragraphs.join("\n"), user_id: Faker::Number.within(range: 1..20))
    a.enqueue
    a.publish
  end
end
