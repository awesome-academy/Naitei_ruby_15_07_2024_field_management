# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.cell_phone_in_e164 }
    role { 0 }
    password { "Password123!" }
    encrypted_password { Devise::Encryptor.digest(User, password) }
    confirmed_at { Time.zone.now }
    confirmation_sent_at { Time.zone.now }
    confirmation_token { SecureRandom.urlsafe_base64 }
  end
end
