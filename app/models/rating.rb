class Rating < ApplicationRecord
  RATING_PARAMS = [:rating, {comment_attributes: [:content]}].freeze
  belongs_to :user
  belongs_to :field
  has_one :comment, dependent: :destroy

  accepts_nested_attributes_for :comment

  validates :rating, presence: true, inclusion: {in: 1..5}
  scope :recent, ->{order(created_at: :desc)}
end
