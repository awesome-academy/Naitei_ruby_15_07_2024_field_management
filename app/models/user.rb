class User < ApplicationRecord
  PERMITTED_ATTRIBUTES = [:name,
                          :email,
                          :password,
                          :password_confirmation].freeze

  VALID_EMAIL_REGEX = Regexp.new(Settings.users.email.regex)

  enum role: {user: 0, admin: 1}

  has_many :addresses, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true

  has_many :booking_fields, dependent: :destroy
  has_many :booked_fields, through: :booking_fields, source: :field

  has_many :favorites, dependent: :destroy
  has_many :favorited_fields, through: :favorites, source: :favoritable,
            source_type: "Field"
  has_many :ratings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :timelines, dependent: :destroy

  has_secure_password

  scope :search_by_name, lambda {|name|
    where("name LIKE ?", "%#{name}%") if name.present?
  }

  validates :name, presence: true,
                   length: {maximum: Settings.users.name.max_length,
                            minimum: Settings.users.name.min_length}

  validates :email, presence: true,
                    format: {with: VALID_EMAIL_REGEX},
                    uniqueness: {case_sensitive: false}

  validate :password_complexity

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end
  end

  private

  def password_complexity
    return if password.blank?

    validate_password_length
    validate_password_lowercase
    validate_password_uppercase
    validate_password_digit
    validate_password_special_char
  end

  def validate_password_length
    return unless password_too_short?

    errors.add(:base,
               I18n.t("activerecord.error.password.too_short"))
  end

  def validate_password_lowercase
    return if password_has_lowercase?

    errors.add(:base,
               I18n.t("activerecord.error.password.missing_lowercase"))
  end

  def validate_password_uppercase
    return if password_has_uppercase?

    errors.add(:base,
               I18n.t("activerecord.error.password.missing_uppercase"))
  end

  def validate_password_digit
    return if password_has_digit?

    errors.add(:base,
               I18n.t("activerecord.error.password.missing_digit"))
  end

  def validate_password_special_char
    return if password_has_special_char?

    errors.add(:base,
               I18n.t("activerecord.error.password.missing_special_char"))
  end

  def password_too_short?
    password.length < Settings.users.password.min_length
  end

  def password_has_lowercase?
    password =~ Regexp.new(Settings.users.password.lowercase)
  end

  def password_has_uppercase?
    password =~ Regexp.new(Settings.users.password.uppercase)
  end

  def password_has_digit?
    password =~ Regexp.new(Settings.users.password.digit)
  end

  def password_has_special_char?
    password =~ Regexp.new(Settings.users.password.special_char)
  end
end
