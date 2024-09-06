class VoucherSerializer < ActiveModel::Serializer
  attributes %i(id code name value expired_date status quantity used_with_other)
  has_many :use_vouchers
end
