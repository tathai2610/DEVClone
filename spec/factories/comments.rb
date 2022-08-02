FactoryBot.define do
  factory :comment do
    association :user

    trait :for_post do
      association :commentable, factory: :post
    end

    trait :for_comment do
      association :commentable, factory: :comment
    end

    content { Faker::Lorem.paragraph }
  end
end
