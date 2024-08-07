class UseVoucher < ApplicationRecord
  belongs_to :voucher
  belongs_to :booking_field
end
