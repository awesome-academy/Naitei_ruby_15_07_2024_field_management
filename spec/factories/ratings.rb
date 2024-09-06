FactoryBot.define do
  factory :rating do
    rating { rand(1..5) }
    association :field
    association :user
  end
end
