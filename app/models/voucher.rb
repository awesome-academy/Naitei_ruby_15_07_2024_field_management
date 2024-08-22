class Voucher < ApplicationRecord
  PERMITTED_ATTRIBUTES = [:code,
                          :name,
                          :value,
                          :expired_date,
                          :status,
                          :quantity].freeze

  before_create :generate_code

  enum status: {available: 0, expired: 1}

  scope :find_with_list_ids, ->(ids){where(id: ids)}

  has_many :use_vouchers, dependent: :destroy
  after_save :check_status

  scope :available_vouchers,
        ->{available.where("expired_date >= ?", Date.current)}

  def decrement_quantity
    return unless quantity.positive?

    decrement!(:quantity)
  end

  private
  def check_status
    return unless quantity.zero?

    voucher.expired!
  end

  def generate_code
    self.code = Faker::Alphanumeric.unique.alpha(number: 10).upcase
  end
end
