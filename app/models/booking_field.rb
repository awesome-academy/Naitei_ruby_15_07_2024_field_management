class BookingField < ApplicationRecord
  BOOKING_PARAMS = %I[field_id date start_time end_time total].freeze
  belongs_to :user
  belongs_to :field

  include PublicActivity::Model
  tracked owner: proc{|controller, _model|
                   controller.current_user if controller.current_user&.user?
                 }, only: [:create]
  before_update :track_status_change

  validate :start_time_must_be_multiple_of_30_minutes,
           :start_time_and_end_time_within_opening_hours,
           :booking_not_overlapping,
           :date_cannot_be_in_the_past,
           :date_must_be_within_two_weeks

  enum status: {pending: 0, approval: 1, canceled: 2}
  enum paymentStatus: {paid: 0, unpaid: 1}

  has_many :use_vouchers, dependent: :destroy
  has_many :vouchers, through: :use_vouchers

  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :total, presence: true, numericality: {greater_than_or_equal_to: 0}

  scope :by_date, ->(date){where(date:) if date.present?}

  scope :by_field_name, lambda {|field_name|
    if field_name.present?
      joins(:field).where("fields.name LIKE ?", "%#{field_name}%")
    end
  }

  scope :by_total_min, lambda {|total_min|
    where("total >= ?", total_min) if total_min.present?
  }

  scope :by_total_max, lambda {|total_max|
    where("total <= ?", total_max) if total_max.present?
  }

  scope :by_status, ->(status){where(status:) if status.present?}
  scope :by_paymentStatus, lambda {|status|
                             where(paymentStatus: status) if status.present?
                           }

  scope :by_start_time, lambda {|start_time|
    where("start_time >= ?", start_time) if start_time.present?
  }

  scope :by_end_time, lambda {|end_time|
    where("end_time <= ?", end_time) if end_time.present?
  }

  scope :sorted_by_date_and_start_time,
        ->{order(date: :desc, start_time: :desc)}

  scope :by_date_range, lambda {|start_date, end_date|
    if start_date.present? && end_date.present?
      where(date: start_date..end_date)
    end
  }

  scope :excluding_status,
        ->(status){where.not(status:) if status.present?}

  scope :future_bookings, ->{where("date >= ?", Time.zone.today)}

  scope :pending_or_approved, ->{where(status: %w(pending approval))}
  scope :existing_books, lambda {|field_id, date, current_id|
                           where(field_id:, date:).where.not(id: current_id)
                         }
  scope :with_status, ->(status){where(status:)}
  scope :yet_book?, lambda {|field_id|
    where(field_id:).with_status(:approval) if field_id.present?
  }

  scope :grouped_revenue, lambda {|analysis_type, date_from, date_to|
    group_by_period(analysis_type.to_sym, :date, range: date_from..date_to)
      .sum(:total)
  }
  scope :revenue_by_capacity, ->{group("fields.capacity").sum(:total)}

  scope :revenue_by_grass, ->{group("fields.grass").sum(:total)}

  def self.ransackable_attributes _auth_object = nil
    %w(date total start_time end_time status paymentStatus)
  end

  def self.ransackable_associations _auth_object = nil
    %w(field)
  end

  def self.filtered params
    by_date(params[:date])
      .by_field_name(params[:field_name])
      .by_total_min(params[:total_min])
      .by_total_max(params[:total_max])
      .by_status(params[:status])
      .by_paymentStatus(params[:paymentStatus])
      .by_start_time(params[:start_time])
      .by_end_time(params[:end_time])
      .sorted_by_date_and_start_time
  end

  def check_vouchers vouchers
    if vouchers&.any? do |voucher|
         !voucher.used_with_other
       end && vouchers.count > 1
      errors.add(:base,
                 I18n.t("activerecord.error.voucher_error"))
      false
    else
      true
    end
  end

  private

  def track_status_change
    if status_changed? && canceled?
      create_activity(:canceled)
    elsif paymentStatus_changed? && paid?
      create_activity(:paid)
    end
  end

  def start_time_must_be_multiple_of_30_minutes
    return unless start_time.min % Settings.time_interval != 0

    errors.add(:start_time,
               I18n.t("activerecord.error.multiple_of_30_minutes"))
    throw(:abort)
  end

  def start_time_and_end_time_within_opening_hours
    field = Field.find(field_id)
    return unless start_time < field.open_time || end_time > field.close_time

    errors.add(:base,
               I18n.t("activerecord.error.within_open_hour"))
    throw(:abort)
  end

  def booking_not_overlapping
    existing_bookings = BookingField.existing_books(field_id, date, id)
    existing_bookings.each do |booking|
      next if booking.canceled?

      if start_time < booking.end_time && end_time > booking.start_time
        errors.add(:base, I18n.t("activerecord.error.overlap_time"))
        throw(:abort)
      end
    end
  end

  def date_cannot_be_in_the_past
    return unless date.present? && date < Time.zone.today

    errors.add(:date, I18n.t("activerecord.error.booking_in_past"))
    throw(:abort)
  end

  def date_must_be_within_two_weeks
    return unless date.present? && date > Settings.two.weeks.from_now.to_date

    errors.add(:date, I18n.t("activerecord.error.two_week_booking"))
    throw(:abort)
  end
end
