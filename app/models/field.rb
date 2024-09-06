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

  ransacker :average_rating do |_parent|
    Arel.sql('( SELECT AVG(ratings.rating)
                FROM ratings
                WHERE ratings.field_id = fields.id
              )')
  end

  def self.ransackable_attributes _auth_object = nil
    %w(name price grass capacity average_rating)
  end

  def self.ransackable_scopes _auth_object = nil
    %i(with_ave_rate)
  end

  def self.ransackable_associations _auth_object = nil
    %w(ratings)
  end

  has_many_attached :images
  has_many :booking_fields, dependent: :destroy
  has_many :users, through: :booking_fields
  has_many :favorites, as: :favoritable, dependent: :destroy
  has_many :ratings, dependent: :destroy

  validates :capacity, presence: true, inclusion: {in: [5, 7, 11]}
  validates :price,
            presence: {message: I18n.t("fields.messages.price.blank")}
  validate :validate_price_range
  validate :validate_name_length
  validate :validate_address_length

  private

  def validate_price_range
    if price.present? &&
       (price < Settings.field.price_min || price > Settings.field.price_max)
      errors.add(:price,
                 I18n.t("fields.messages.price.invalid_range",
                        min: Settings.field.price_min,
                        max: Settings.field.price_max))
    end
  end

  def validate_name_length
    if name.blank?
      add_name_blank_error
    else
      check_name_length
    end
  end

  def add_name_blank_error
    errors.add(:name, I18n.t("fields.messages.name.blank"))
  end

  def check_name_length
    if name.length < Settings.field.name_min_len
      errors.add(:name, I18n.t("fields.messages.name.too_short",
                               count: Settings.field.name_min_len))
    elsif name.length > Settings.field.name_max_len
      errors.add(:name, I18n.t("fields.messages.name.too_long",
                               count: Settings.field.name_max_len))
    end
  end

  def validate_address_length
    if address.blank?
      add_address_blank_error
    else
      check_address_length
    end
  end

  def add_address_blank_error
    errors.add(:address, I18n.t("fields.messages.address.blank"))
  end

  def check_address_length
    if address.length < Settings.field.address_min_len
      errors.add(:address, I18n.t("fields.messages.address.too_short",
                                  min: Settings.field.address_min_len))
    elsif address.length > Settings.field.address_max_len
      errors.add(:address, I18n.t("fields.messages.address.too_long",
                                  max: Settings.field.address_max_len))
    end
  end
end
