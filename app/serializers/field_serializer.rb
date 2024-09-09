class FieldSerializer < ActiveModel::Serializer
  attributes %i(id name price grass capacity open_time close_time block_time
                address)
  has_many :booking_fields
  has_many :users
  has_many :favorites
  has_many :ratings
end
