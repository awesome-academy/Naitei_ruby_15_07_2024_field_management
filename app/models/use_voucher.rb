class UseVoucher < ApplicationRecord
  belongs_to :voucher
  belongs_to :booking_field

  after_save :decrement_voucher_quantity

  private
  def decrement_voucher_quantity
    voucher.decrement_quantity
  end
end
