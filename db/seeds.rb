require "faker"
require "open-uri"

User.create!(
  name: "team2_soccer",
  email: "user@test.com",
  phone: Faker::PhoneNumber.cell_phone_in_e164,
  password: "Egh987ns!",
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
    password: "Egh987ns!",
    role: :user,
    activated: Time.zone.now,
    activated_at: DateTime.now
  )
end

# Create admin and regular user
User.create!(
  name: "admin123",
  email: "admin@test.com",
  phone: Faker::PhoneNumber.cell_phone_in_e164,
  password: "Egh987ns!",
  role: :admin,
  activated: true,
  activated_at: DateTime.now
)


# Create fields with attached images
fields = 20.times.map do
  field = Field.create!(
    name: "#{Faker::Sports::Football.team} #{rand(100..999)}",
    price: Faker::Commerce.price(range: 50.0..200.0),
    grass: [:natural, :artificial].sample,
    capacity: [5, 7, 11].sample,
    open_time: Time.parse("08:00"),  # Use Time instead of DateTime
    close_time: Time.parse("22:00"), # Use Time instead of DateTime
    block_time: 1
  )
  image_url_prefix = if field.capacity == 11
    "https://res.cloudinary.com/dlgyapagf/image/upload/v1724318520/Soccer-field/intern_sun_field11_f#{rand(1..9)}"
  elsif field.capacity == 5
    "https://res.cloudinary.com/dlgyapagf/image/upload/v1724318520/Soccer-field/intern_sun_field7_f#{rand(1..14)}"
  else
    "https://res.cloudinary.com/dlgyapagf/image/upload/v1724318519/Soccer-field/intern_sun_field5_f#{rand(1..4)}"
  end

3.times do
  image_url = "#{image_url_prefix}.jpg"
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

# # Helper method to generate random time in half-hour increments with a minimum duration of 1 hour and 30 minutes and a maximum of 3 hours
# def random_time_between_8am_and_10pm
#   start_time = Time.new(2000, 1, 1, 8, 0, 0) # Using an arbitrary date, since only the time is needed
#   end_time = Time.new(2000, 1, 1, 22, 0, 0) # 10:00 PM

#   random_time = Time.at(rand(start_time.to_i..end_time.to_i))

#   # Optionally, round to the nearest 30 minutes
#   random_time.change(min: (random_time.min / 30) * 30).strftime("%H:%M")
# end

# Assign addresses and create bookings and favorites for users
users.first(5).each do |user|
  2.times do
    Address.create!(
      user: user,
      address: Faker::Address.full_address
    )
  end

  2.times do
    field = fields.sample
    date = rand(0..13).days.from_now.to_date # Random date within 2 weeks from now
  
    # Generate start and end times within the field's open and close times
    start_time = Time.parse("09:00") # Use Time instead of DateTime
    end_time = Time.parse("10:00")# Use Time instead of DateTime
  
    # Ensure no overlapping bookings unless the existing booking is canceled
    existing_bookings = BookingField.existing_books(field.id, date, nil)
    overlap = existing_bookings.any? do |booking|
      !booking.canceled? && start_time < booking.end_time && end_time > booking.start_time
    end
  
    next if overlap # Skip this booking if it overlaps with a non-canceled booking
  
    BookingField.create!(
      user: user,
      field: field,
      date: date,
      start_time: start_time,
      end_time: end_time,
      total: field.price,
      status: :canceled
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
