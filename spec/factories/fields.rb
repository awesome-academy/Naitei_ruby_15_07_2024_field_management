FactoryBot.define do
  factory :field do
    name { "#{Faker::Sports::Football.team} #{rand(100..999)}" }
    price { Faker::Commerce.price(range: 50.0..200.0) }
    grass { [:natural, :artificial].sample }
    capacity { [5, 7, 11].sample }
    open_time { Time.parse("08:00").strftime(Settings.calendar.time_format) }
    close_time { Time.parse("22:00").strftime(Settings.calendar.time_format) }
  end
end
