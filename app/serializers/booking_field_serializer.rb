class BookingFieldSerializer < ActiveModel::Serializer
  attributes %i(id user_id field_id date start_time end_time total status
                  paymentStatus)
  belongs_to :user
  belongs_to :field
  has_many :use_vouchers
  has_many :vouchers
end
