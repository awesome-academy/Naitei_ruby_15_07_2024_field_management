FactoryBot.define do
  factory :voucher do
    code { Faker::Alphanumeric.unique.alpha(number: 10).upcase }
    name { Faker::Commerce.product_name }
    value { Faker::Commerce.price(range: 10.0..50.0) }
    expired_date { Faker::Date.forward(days: 90) }
    status { :available }
    quantity { Faker::Number.between(from: 1, to: 100) }
  end
end
