class BookingField < ApplicationRecord
  belongs_to :user
  belongs_to :field

  enum status: {pending: 0, approval: 1, canceled: 2}

  has_many :use_vouchers, dependent: :destroy

  validates :date, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :total, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :status, presence: true

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

  scope :by_start_time, lambda {|start_time|
    where("start_time >= ?", start_time) if start_time.present?
  }

  scope :by_end_time, lambda {|end_time|
    where("end_time <= ?", end_time) if end_time.present?
  }

  scope :sorted_by_date_and_start_time,
        ->{order(date: :desc, start_time: :desc)}

  def self.filtered params
    by_date(params[:date])
      .by_field_name(params[:field_name])
      .by_total_min(params[:total_min])
      .by_total_max(params[:total_max])
      .by_status(params[:status])
      .by_start_time(params[:start_time])
      .by_end_time(params[:end_time])
      .sorted_by_date_and_start_time
  end
end
