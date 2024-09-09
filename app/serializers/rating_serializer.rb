class RatingSerializer < ActiveModel::Serializer
  attributes %i(id field_id rating created_at)
  belongs_to :field
  has_one :comment
end
