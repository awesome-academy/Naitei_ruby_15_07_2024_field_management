require "rails_helper"

RSpec.describe Field, type: :model do
  describe "validations" do
    context "when all attributes are valid" do
      it "is valid with valid attributes" do
        field = FactoryBot.build(:field)
        expect(field).to be_valid
      end
    end

    context "when capacity is invalid" do
      it "is invalid without capacity" do
        field = FactoryBot.build(:field, capacity: nil)
        field.validate
        expect(field.errors[:capacity]).to include(I18n.t("fields.messages.capacity.blank"))
      end

      it "is invalid with capacity not in [5, 7, 11]" do
        field = FactoryBot.build(:field, capacity: 9)
        field.validate
        expect(field.errors[:capacity]).to include(I18n.t("fields.messages.capacity.invalid"))
      end
    end

    context "when price is invalid" do
      it "is invalid without price" do
        field = FactoryBot.build(:field, price: nil)
        field.validate
        expect(field.errors[:price]).to include(I18n.t("fields.messages.price.blank"))
      end

      it "is invalid with price less than the minimum" do
        field = FactoryBot.build(:field, price: Settings.field.price_min - 1)
        field.validate
        expect(field.errors[:price]).to include(I18n.t("fields.messages.price.invalid_range", min: Settings.field.price_min, max: Settings.field.price_max))
      end

      it "is invalid with price greater than the maximum" do
        field = FactoryBot.build(:field, price: Settings.field.price_max + 1)
        field.validate
        expect(field.errors[:price]).to include(I18n.t("fields.messages.price.invalid_range", min: Settings.field.price_min, max: Settings.field.price_max))
      end
    end

    context "when name is invalid" do
      it "is invalid without name" do
        field = FactoryBot.build(:field, name: nil)
        field.validate
        expect(field.errors[:name]).to include(I18n.t("fields.messages.name.blank"))
      end

      it "is invalid when name is too short" do
        field = FactoryBot.build(:field, name: "A" * (Settings.field.name_min_len - 1))
        field.validate
        expect(field.errors[:name]).to include(I18n.t("fields.messages.name.too_short", count: Settings.field.name_min_len))
      end

      it "is invalid when name is too long" do
        field = FactoryBot.build(:field, name: "A" * (Settings.field.name_max_len + 1))
        field.validate
        expect(field.errors[:name]).to include(I18n.t("fields.messages.name.too_long", count: Settings.field.name_max_len))
      end
    end

    context "when address is invalid" do
      it "is invalid without address" do
        field = FactoryBot.build(:field, address: nil)
        field.validate
        expect(field.errors[:address]).to include(I18n.t("fields.messages.address.blank"))
      end

      it "is invalid when address is too short" do
        field = FactoryBot.build(:field, address: "Short")
        field.validate
        expect(field.errors[:address]).to include(I18n.t("fields.messages.address.too_short", min: Settings.field.address_min_len))
      end

      it "is invalid when address is too long" do
        field = FactoryBot.build(:field, address: "A" * (Settings.field.address_max_len + 1))
        field.validate
        expect(field.errors[:address]).to include(I18n.t("fields.messages.address.too_long", max: Settings.field.address_max_len))
      end
    end
  end

  describe "associations" do
    it { should have_many(:booking_fields).dependent(:destroy) }
    it { should have_many(:users).through(:booking_fields) }
    it { should have_many(:favorites).dependent(:destroy) }
    it { should have_many(:ratings).dependent(:destroy) }
  end

  describe "enums" do
    it { should define_enum_for(:grass).with_values(natural: 0, artificial: 1) }
  end

  describe "scopes" do
    describe ".filter_by_name" do
      it "returns fields with name matching the query" do
        field1 = FactoryBot.create(:field, name: "Field A", price: 50000)
        field2 = FactoryBot.create(:field, name: "Field B", price: 60000)

        expect(Field.filter_by_name("A")).to include(field1)
        expect(Field.filter_by_name("A")).not_to include(field2)
      end
    end

    describe ".sort_by_price" do
      it "sorts fields by price" do
        field1 = FactoryBot.create(:field, price: 50000)
        field2 = FactoryBot.create(:field, price: 60000)

        expect(Field.sort_by_price("asc")).to eq([field1, field2])
        expect(Field.sort_by_price("desc")).to eq([field2, field1])
      end
    end

    describe ".with_ave_rate" do
      it "returns fields with average ratings" do
        field = FactoryBot.create(:field, price: 50000)
        FactoryBot.create(:rating, field: field, rating: 4)
        FactoryBot.create(:rating, field: field, rating: 5)

        expect(Field.with_ave_rate.first.average_rating.to_f).to eq(4.5)
      end
    end
  end

  describe ".with_ave_rate" do
    it "returns fields with average ratings" do
      field = FactoryBot.create(:field, price: 50000)
      FactoryBot.create(:rating, field: field, rating: 4)
      FactoryBot.create(:rating, field: field, rating: 5)

      expect(Field.with_ave_rate.first.average_rating.to_f).to eq(4.5)
    end
  end
end
