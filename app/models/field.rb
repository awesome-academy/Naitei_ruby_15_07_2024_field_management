class Field < ApplicationRecord
  enum grass: {natural: 0, artificial: 1}

  has_many :booking_fields, dependent: :destroy
  has_many :users, through: :booking_fields
  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  validates :capacity, presence: true, inclusion: {in: [5, 7, 11]}
end
