class User < ApplicationRecord
  enum role: {user: 0, admin: 1}

  has_many :addresses, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true

  has_many :booking_fields, dependent: :destroy
  has_many :booked_fields, through: :booking_fields, source: :field

  has_many :favorites, dependent: :destroy
  has_many :favorited_fields, through: :favorites, source: :favoritable,
            source_type: "Field"
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :timelines, dependent: :destroy

  has_secure_password
end
