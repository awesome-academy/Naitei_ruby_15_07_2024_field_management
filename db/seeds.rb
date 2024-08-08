User.create!(
  name: "admin",
  email: "admin@test.com",
  password: "123456",
  role: :admin,
  activated: true,
  activated_at: DateTime.now
)

User.create!(
  name: "user",
  email: "user@test.com",
  password: "123456",
  role: :user,
  activated: true,
  activated_at: DateTime.now
)

users = 30.times.map do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    password: "123456",
    role: :user,
    activated: true,
    activated_at: DateTime.now
  )
end

fields = 20.times.map do
  Field.create!(
    name: Faker::Sports::Football.team,
    price: Faker::Commerce.price(range: 50.0..200.0),
    grass: [:natural, :artificial].sample,
    capacity: [5, 7, 11].sample,
    open_time: DateTime.parse("2023-01-01 08:00"),
    close_time: DateTime.parse("2023-01-01 22:00"),
    block_time: 0
  )
end

5.times.map do
  Voucher.create!(
    code: Faker::Alphanumeric.unique.alpha(number: 10).upcase,
    name: Faker::Commerce.product_name,
    value: Faker::Commerce.price(range: 10.0..50.0),
    expired_date: Faker::Date.forward(days: 90),
    status: 0,
    quantity: Faker::Number.between(from: 1, to: 100)
  )
end

users.each do |user|
  2.times do
    Address.create!(
      user: user,
      address: Faker::Address.full_address
    )
  end

  # 10 Booking Fields per User
  10.times do
    field = fields.sample
    BookingField.create!(
      user: user,
      field: field,
      date: Faker::Date.forward(days: 30),
      start_time: DateTime.now + rand(1..12).hours,
      end_time: DateTime.now + rand(13..24).hours,
      total: field.price,
      status: [:pending, :approval, :canceled].sample
    )
  end

  # 5 Favorited Fields per User
  5.times do
    Favorite.create!(
      user: user,
      favoritable: fields.sample
    )
  end
end

puts "Seed data created successfully!"
