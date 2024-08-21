require "faker"
require "open-uri"

# Create admin and regular user
User.create!(
  name: "admin",
  email: "admin@test.com",
  phone: Faker::PhoneNumber.cell_phone_in_e164,
  password: "123456",
  role: :admin,
  activated: true,
  activated_at: DateTime.now
)

User.create!(
  name: "user",
  email: "user@test.com",
  phone: Faker::PhoneNumber.cell_phone_in_e164,
  password: "123456",
  role: :user,
  activated: true,
  activated_at: DateTime.now
)

# Create additional users
users = 30.times.map do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.cell_phone_in_e164,
    password: "123456",
    role: :user,
    activated: Time.zone.now,
    activated_at: DateTime.now
  )
end

# Create fields with attached images
fields = 20.times.map do
  field = Field.create!(
    name: "#{Faker::Sports::Football.team} #{rand(100..999)}",
    price: Faker::Commerce.price(range: 50.0..200.0),
    grass: [:natural, :artificial].sample,
    capacity: [5, 7, 11].sample,
    open_time: DateTime.parse("2023-01-01 08:00"),
    close_time: DateTime.parse("2023-01-01 22:00"),
    block_time: 1
  )

  3.times do
    image_url = "https://res.cloudinary.com/dlgyapagf/image/upload/v1723106081/Soccer-field/intern_sun_f#{rand(1..3)}.jpg"
    downloaded_image = URI.open(image_url)
    field.images.attach(io: downloaded_image, filename: "field#{rand(1..3)}.png")
  end

  field
end

# Create vouchers
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

# Helper method to generate random time in half-hour increments with a minimum duration of 1 hour and 30 minutes and a maximum of 3 hours
def random_time_between(start_hour, end_hour)
  start_minute = [0, 30].sample
  start_time = DateTime.now.change({ hour: start_hour, min: start_minute })

  end_time = start_time + (rand(3..6) * 30).minutes

  while end_time.hour > 23 || (end_time.hour == 23 && end_time.minute > 30)
    start_hour = rand(6..20)
    start_minute = [0, 30].sample
    start_time = DateTime.now.change({ hour: start_hour, min: start_minute })
    end_time = start_time + (rand(3..6) * 30).minutes
  end

  [start_time, end_time]
end

# Assign addresses and create bookings and favorites for users
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
    start_hour = rand(6..20)
    start_time, end_time = random_time_between(start_hour, start_hour + 6)

    BookingField.create!(
      user: user,
      field: field,
      date: Faker::Date.forward(days: 30),
      start_time: start_time,
      end_time: end_time,
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
