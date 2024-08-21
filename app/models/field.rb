class Field < ApplicationRecord
  PERMITTED_ATTRIBUTES = [:name,
  :price,
  :grass,
  :capacity,
  :open_time,
  :close_time,
  :address].freeze

  enum grass: {natural: 0, artificial: 1}

  scope :filter_by_name, lambda {|name|
                           where("name LIKE ?", "%#{name}%") if name.present?
                         }
  scope :filter_by_grass, lambda {|grass_type|
                            where(grass: grass_type) if grass_type.present?
                          }
  scope :filter_by_capacity, lambda {|capacity_type|
                               if capacity_type.present?
                                 where(capacity: capacity_type)
                               end
                             }
  scope :sort_by_price, lambda {|direction|
                          order(price: direction) if direction.present?
                        }
  scope :with_ave_rate, lambda {left_joins(:ratings) # rubocop:disable Layout/MultilineBlockLayout
    .select("fields.*, AVG(ratings.rating) as average_rating")
    .group("fields.id")
                        }

  scope :favorited_by, lambda {|user, favorites_param|
    return unless favorites_param.present? && user.present?

    joins(:favorites).where(favorites: {user_id: user.id})
  }

  has_many_attached :images
  has_many :booking_fields, dependent: :destroy
  has_many :users, through: :booking_fields
  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  validates :capacity, presence: true, inclusion: {in: [5, 7, 11]}
  validates :price, presence: true
end
