class Voucher < ApplicationRecord
  enum status: {available: 0, expired: 1}

  has_many :use_vouchers, dependent: :destroy
end
