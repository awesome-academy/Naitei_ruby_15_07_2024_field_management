class BookingFieldSerializer < ActiveModel::Serializer
  attributes %i(date start_time end_time status)

  attribute :id, if: ->{instance_options[:current_user]&.admin?}
  attribute :user_id, if: ->{instance_options[:current_user]&.admin?}
  attribute :field_id, if: ->{instance_options[:current_user]&.admin?}
  attribute :total, if: ->{instance_options[:current_user]&.admin?}
  attribute :paymentStatus, if: ->{instance_options[:current_user]&.admin?}

  belongs_to :user, if: ->{instance_options[:current_user]&.admin?}
  belongs_to :field, if: ->{instance_options[:current_user]&.admin?}
  has_many :use_vouchers, if: ->{instance_options[:current_user]&.admin?}
  has_many :vouchers, if: ->{instance_options[:current_user]&.admin?}
end
