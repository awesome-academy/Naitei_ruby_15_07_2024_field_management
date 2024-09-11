class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable,
         :confirmable, :lockable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  PERMITTED_ATTRIBUTES = [:name,
                          :email,
                          :password,
                          :password_confirmation].freeze

  VALID_EMAIL_REGEX = Regexp.new(Settings.users.email.regex)

  before_save :downcase_email

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

    def new_token
      SecureRandom.urlsafe_base64
    end

    def from_omniauth access_token
      data = access_token.info
      provider = access_token.provider
      user = User.find_by email: data["email"]

      user ||= User.create(name: data["name"],
                           email: data["email"],
                           password: Settings.default_password,
                           provider:)
      user
    end
  end

  def self.ransackable_attributes auth_object = nil
    auth_object == :admin ? %w(name email phone) : []
  end

  def self.ransackable_associations _auth_object = nil
    []
  end

  private

  def downcase_email
    email.downcase!
  end

  def password_complexity
    return if password.blank?

    validate_password_length
    validate_password_lowercase
    validate_password_uppercase
    validate_password_digit
    validate_password_special_char
    validate_password_not_same_as_old
    validate_password_not_same_as_name_or_email
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

  def validate_password_not_same_as_old
    return unless encrypted_password.present? && encrypted_password_was.present?

    begin
      old_password = BCrypt::Password.new(encrypted_password_was)
      if old_password.is_password?(password)
        errors.add(:password,
                   I18n.t("activerecord.error.password.same_as_old"))
      end
    rescue BCrypt::Errors::InvalidHash
      errors.add(:password,
                 I18n.t("activerecord.error.password.invalid_old_hash"))
    end
  end

  def validate_password_not_same_as_name_or_email
    if password.downcase.include? name.downcase
      errors.add(:password,
                 I18n.t("activerecord.error.password.same_as_name"))
    end

    return unless password.downcase.include?(email.split("@").first.downcase)

    errors.add(:password,
               I18n.t("activerecord.error.password.same_as_email"))
  end
end
