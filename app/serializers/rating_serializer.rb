class RatingSerializer < ActiveModel::Serializer
  attributes %i(id field_id rating created_at user_id)
  has_one :comment
end
