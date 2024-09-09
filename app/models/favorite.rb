class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favoritable, polymorphic: true

  include PublicActivity::Model
  tracked owner: ->(controller, _model){controller&.current_user}
end
