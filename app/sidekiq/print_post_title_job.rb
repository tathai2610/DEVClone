class PrintPostTitleJob
  include Sidekiq::Job

  def perform(*posts)
    posts.each do |post|
      puts post.id + " " + post.title
    end
  end
end
