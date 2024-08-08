class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :field

  validates :rating, presence: true, inclusion: {in: 1..5}
end
