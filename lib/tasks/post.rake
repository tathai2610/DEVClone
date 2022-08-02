namespace :post do
  desc "TODO"
  task create_random: :environment do
    CreateRandomPostsJob.perform_later
  end

end
