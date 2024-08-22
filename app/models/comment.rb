class Comment < ApplicationRecord
  COMMENT_PARAMS = %I[content].freeze

  belongs_to :rating
  belongs_to :parent, class_name: Comment.name, optional: true
  has_many :replies, class_name: Comment.name, foreign_key: :parent_id,
            dependent: :destroy
end
