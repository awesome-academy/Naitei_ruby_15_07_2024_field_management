class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :favoritable, polymorphic: true

  include PublicActivity::Model
  tracked owner: proc{|controller, _model|
                   controller.current_user if controller.current_user&.user?
                 }
end
