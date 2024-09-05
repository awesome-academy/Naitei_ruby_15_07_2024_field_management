require "rails_helper"

RSpec.describe BookingField, type: :model do
  before do
    allow_any_instance_of(PublicActivity::Common).to receive(:create_activity)
  end

  describe "associations" do
    it { should belong_to(:user).without_validating_presence }
    it { should belong_to(:field).without_validating_presence }
    describe "has many" do
      it { should have_many(:use_vouchers).dependent(:destroy) }
      it { should have_many(:vouchers).through(:use_vouchers) }
    end
  end

  describe "validations" do

    describe "presence_of" do
      subject{create :booking_field}

      it { is_expected.to validate_presence_of(:date) }
      it { is_expected.to validate_presence_of(:total) }
      it { is_expected.to validate_numericality_of(:total).is_greater_than_or_equal_to(0) }
    end

    describe "validate" do
      let(:field) { create(:field)}
      let(:booking_field) { build(:booking_field, field: field) }

      context "start_time must be multiple of 30 minutes" do
        it "is valid when start_time is a multiple of 30 minutes" do
          booking_field.start_time = Time.parse("08:30").strftime("%H:%M")
          expect(booking_field).to be_valid
        end

        it "is invalid when start_time is not a multiple of 30 minutes" do
          booking_field.start_time = Time.parse("08:25").strftime("%H:%M")
          expect(booking_field).to be_invalid
          expect(booking_field.errors[:start_time]).to include(I18n.t("activerecord.error.multiple_of_30_minutes"))
        end
      end

      context "start_time and end_time within opening hours" do
        it "is valid when within opening hours" do
          booking_field.start_time = field.open_time + 1.hour
          booking_field.end_time = booking_field.start_time + 1.hour
          expect(booking_field).to be_valid
        end

        it "is invalid when outside opening hours" do
          booking_field.start_time = Time.zone.parse("07:00")
          booking_field.end_time = booking_field.start_time + 1.hour
          expect(booking_field).to be_invalid
          expect(booking_field.errors[:base]).to include(I18n.t("activerecord.error.within_open_hour"))
        end
      end

      context "booking not overlapping" do
        it "is invalid when booking overlaps with another booking" do
          create(:booking_field, field: field, date: booking_field.date, start_time: field.open_time + 1.hour, end_time: field.open_time + 2.hours)
          booking_field.start_time = field.open_time + 1.hour
          booking_field.end_time = field.open_time + 2.hours
          expect(booking_field).to be_invalid
          expect(booking_field.errors[:base]).to include(I18n.t("activerecord.error.overlap_time"))
        end

        it "is valid when booking does not overlap" do
          create(:booking_field, field: field, date: booking_field.date, start_time: field.open_time, end_time: field.open_time + 1.hour)
          booking_field.start_time = field.open_time + 1.hour
          booking_field.end_time = field.open_time + 2.hours
          expect(booking_field).to be_valid
        end
      end

      context "date cannot be in the past" do
        it "is invalid when date is in the past" do
          booking_field.date = 2.days.ago
          expect(booking_field).to be_invalid
          expect(booking_field.errors[:date]).to include(I18n.t("activerecord.error.booking_in_past"))
        end

        it "is valid when date is today or in the future" do
          booking_field.date = Time.zone.today
          expect(booking_field).to be_valid
        end
      end

      context "date must be within two weeks" do
        it "is invalid when date is more than two weeks from now" do
          booking_field.date = 3.weeks.from_now.to_date
          expect(booking_field).to be_invalid
          expect(booking_field.errors[:date]).to include(I18n.t("activerecord.error.two_week_booking"))
        end

        it "is valid when date is within two weeks" do
          booking_field.date = 1.week.from_now.to_date
          expect(booking_field).to be_valid
        end
      end
    end
  end

  describe "scopes" do
    let!(:field1) { create(:field, capacity: 5, grass: :natural) }
    let!(:field2) { create(:field, capacity: 7, grass: :artificial) }

    describe ".yet_book?" do
      let!(:user1) { create(:user)}
      let!(:user1_booking) { create(:booking_field, user: user1, field: field1, date: Date.today, status: :approval, total: 200) }
      let!(:not_user1_booking) { create(:booking_field, field: field2, date: Date.today, status: :pending, total: 150) }
      
      context "returns user bookings for a specific field" do
        it "when returns the expected result" do
          result = user1.booking_fields.yet_book?(field1.id)
          expect(result).to include(user1_booking)
        end
        it "when returns the unexpected result" do
          result = user1.booking_fields.yet_book?(field2.id)
          expect(result).not_to include(not_user1_booking)
        end
      end

      context "returns user bookings for a nil field" do
        it "returns all" do
          expect(user1.booking_fields.yet_book? nil).to be_empty
        end
      end
    end

    describe "revenue" do
      let(:specific_date) { 12.days.from_now.to_date }
      let!(:revenue_booking1) { create(:booking_field, field: field1, date: specific_date, status: :approval, total: 200) }
      let!(:revenue_booking2) { create(:booking_field, field: field2, date: specific_date, status: :pending, total: 150) }

      describe ".grouped_revenue" do
        context "normal case" do
          it "when returns the expected result" do
            result = BookingField.grouped_revenue(:day, specific_date, specific_date)
            expect(result).to eq({ specific_date => 350.0 })
          end

          it "when returns the unexpected result" do
            result = BookingField.grouped_revenue(:day, specific_date, specific_date)
            expect(result).not_to eq({ specific_date => 400.0 })
          end
        end

        context "provided with no analysis type" do
          it "return empty" do
            result = BookingField.grouped_revenue(nil, specific_date, specific_date)
            expect(result).to be_empty
          end
        end

        context "provided with no date_from type" do
          it "return empty" do
            result = BookingField.grouped_revenue(:day, nil, specific_date)
            expect(result).to be_empty
          end
        end

        context "provided with no date_to type" do
          it "return empty" do
            result = BookingField.grouped_revenue(:day, specific_date, nil )
            expect(result).to be_empty
          end
        end
      end

      describe ".revenue_by_capacity" do
        context "when returns the expected result" do
          it "return capcity with revenue in order" do
            result = BookingField.left_joins(:field).revenue_by_capacity
            expect(result).to eq({ 5 => 200.0, 7 => 150.0 })
          end
        end

        context "when returns the unexpected result" do
          it "return capcity with revenue in un-order" do
            result = BookingField.left_joins(:field).revenue_by_capacity
            expect(result).not_to eq({ 5 => 300, 7 => 150 })
          end
        end
      end

      describe ".revenue_by_grass" do
        context "when returns the expected result" do
          it "calculates total revenue grouped by grass type" do
            result = BookingField.left_joins(:field).revenue_by_grass
            expect(result).to eq({ "natural" => 200.0, "artificial" => 150.0 })
          end
        end

        context "when returns the unexpected result" do
          it "calculates total revenue grouped by grass type" do
            result = BookingField.left_joins(:field).revenue_by_grass
            expect(result).not_to eq({ "natural" => 300, "artificial" => 150 })
          end
        end
      end
    end
    
    describe ".excluding_status" do
      let!(:approved_booking) { create(:booking_field, status: :approval) }
      let!(:pending_booking) { create(:booking_field, status: :pending) }
      let!(:canceled_booking) { create(:booking_field, status: :canceled) }

      context "when a specific status is provided" do
        it "excludes bookings with the provided status" do
          result = BookingField.excluding_status(:pending)
          expect(result).to include(approved_booking, canceled_booking)
          expect(result).not_to include(pending_booking)
        end
      end

      context "when status is nil or not provided" do
        it "returns all bookings" do
          result = BookingField.excluding_status(nil)
          expect(result).to be_empty
        end
      end
  
      context "when status is not present" do
        it "returns all bookings" do
          result = BookingField.excluding_status("")
          expect(result).to be_empty
        end
      end
    end
  end
end
