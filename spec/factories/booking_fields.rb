FactoryBot.define do
  factory :booking_field do
    association :user
    association :field
    date{Time.zone.today}
    start_time{Time.parse("08:30").strftime(Settings.calendar.time_format)}
    end_time{Time.parse("09:30").strftime(Settings.calendar.time_format)}              
    total{100}
    status{:pending}
  end
end
