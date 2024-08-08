class BookingField < ApplicationRecord
  belongs_to :user
  belongs_to :field

  enum status: {pending: 0, approval: 1, canceled: 2}

  has_many :use_vouchers, dependent: :destroy
end
