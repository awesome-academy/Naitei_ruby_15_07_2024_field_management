require "rails_helper"

RSpec.describe User::BookingFieldsController, type: :controller do
  include Devise::Test::ControllerHelpers

  before do
    allow_any_instance_of(PublicActivity::Common).to receive(:create_activity)
  end

  let(:user) { create(:user)}
  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET #index" do
    let!(:field1) { create(:field) }
    let!(:field2) { create(:field) }
    let!(:booking1) { create(:booking_field, user: user, field: field1) }
    let!(:booking2) { create(:booking_field, user: user, field: field2) }
    
    it "assigns @q as a Ransack object for filtering" do
      get :index, params: { q: { total_gteq: 150 } }
      expect(assigns(:q)).to be_a(Ransack::Search)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "PATCH #update" do
    let(:booking_field) { create(:booking_field, user: user, status: :pending) }
    context "when canceling a booking" do
      it "changes the status to canceled and sends a notification" do
        expect(BookingFieldMailer).to receive(:status_change_notification).with(booking_field).and_return(double(deliver_now: true))
        
        patch :update, params: { id: booking_field.id, canceled: true }

        booking_field.reload
        expect(booking_field.status).to eq("canceled")
        expect(flash[:success]).to eq(I18n.t("user.booking_fields.cancel_booking_successfully"))
        expect(response).to redirect_to(user_history_path)
      end
    end

    context "when paying for a booking" do
      it "redirects to the payment page" do
        patch :update, params: { id: booking_field.id, paid: true }

        expect(response).to redirect_to(pay_user_booking_field_path(booking_field))
      end
    end

    context "when neither canceling nor paying" do
      it "does not change the booking status or send a notification" do
        expect(BookingFieldMailer).not_to receive(:status_change_notification)

        patch :update, params: { id: booking_field.id }

        booking_field.reload
        expect(booking_field.status).to eq("pending")
        expect(flash[:success]).to be_nil
        expect(response).not_to redirect_to(pay_user_booking_field_path(booking_field))
      end
    end
  end

  describe "POST #create" do
    let!(:field) { create(:field) }
    let!(:booking_params_invalid) do
      {
        field_id: field.id,
        start_time: Time.parse("08:30").strftime(Settings.calendar.time_format),
        end_time: Time.parse("09:30").strftime(Settings.calendar.time_format),
        total: 100,
        abc: "afaa"
      }
    end 
    let!(:booking_params) do
          {
            field_id: field.id,
            date: Time.zone.today,
            start_time: Time.parse("08:30").strftime(Settings.calendar.time_format),
            end_time: Time.parse("09:30").strftime(Settings.calendar.time_format),
            total: 100
          }
    end
    let(:voucher) { create(:voucher) }

    context "when no voucher_ids are passed" do
      let!(:voucher) { [] }
      let(:voucher_ids) { [] }
      context "when booking is valid" do
        it_behaves_like "successful booking creation"
      end

      context "when the booking is invalid" do
        it_behaves_like "failed booking creation"
      end
    end

    context "when vouchers are passed as params" do
      let!(:voucher) { create(:voucher) }
      let(:voucher_ids) { [voucher.id] }

      context "when booking is valid" do
        it_behaves_like "successful booking creation"
      end

      context "when the booking is invalid" do
        it_behaves_like "failed booking creation"
      end
    end
  end

  describe "GET #new" do
    context "when the field is not found" do
      before do
        allow(Field).to receive(:find_by).and_return(nil)
        get :new, params: { field_id: 999 }
      end

      it "flash and redirects to fields_path" do
        expect(flash[:danger]).to eq I18n.t("user.booking_fields.field_not_found")
        expect(response).to redirect_to(fields_path)
      end
    end
    context "when the field is found" do
      let!(:field) { create(:field) }
      let!(:vouchers) { create_list(:voucher, 2) }

      before do
        allow(Field).to receive(:find_by).and_return(field)
        get :new, params: { field_id: field.id }
      end

      it "renders the :new template" do
        expect(assigns(:booking_field)).to be_a_new(BookingField)
        expect(assigns(:vouchers)).to eq(Voucher.available_vouchers)
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #pay" do
    let!(:booking_field) { create(:booking_field, user: user) }
    it "renders the show_pay template" do
        get :pay, params: { id: booking_field.id }
        expect(response).to have_http_status(:ok)
        expect(response).to render_template(:show_pay)
    end
  end

  describe "GET #demo_payment" do
    context "when booking_field is successfully updated" do
      let!(:booking_field) { create(:booking_field, user: user, status: :pending) }  
      before do
        get :demo_payment, params: { id: booking_field.id }
        booking_field.reload
      end
      it "updates the booking_field to approval status and paid status" do
        expect(booking_field.status).to eq("approval")
        expect(booking_field.paymentStatus).to eq("paid")
      end
      
      it "flash and redirects to root_path" do
        expect(flash[:success]).to eq(I18n.t("user.booking_fields.booking_success"))
        expect(response).to redirect_to(root_path)
      end

    end
  end

  describe "GET #export" do
    let(:job_id) { "job_id" }
    let!(:field) { create(:field) }
    let!(:booking_fields) { create_list(:booking_field,1, user: user, field: field) }

    before do
      allow(ExportBookingJob).to receive(:perform_async).and_return(job_id)
    end

    context "when exporting booking fields" do
      before do
        get :export, format: :json, params: { q: { field_id_eq: field.id } }
      end
      it "assigns @bookings_export with the correct bookings" do
        expect(assigns(:bookings_export)).to match_array(booking_fields)
      end
      it "queues the ExportBookingJob with booking field data" do
        expected_data = booking_fields.as_json(include: [:field])
        expect(ExportBookingJob).to have_received(:perform_async).with(expected_data)
      end
      it "renders the correct JSON with job id" do
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["jid"]).to eq(job_id)
      end
      it "responds with JSON format and responds with success status" do
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET #export_status" do
    let(:job_id) { "job_id" }
    let(:job_status) { { status: "complete" } }
    let(:percent_complete) { 50 }
    before do
      allow(Sidekiq::Status).to receive(:get_all).with(job_id).and_return(job_status)
      allow(Sidekiq::Status).to receive(:pct_complete).with(job_id).and_return(percent_complete)
    end
    context "when format is JSON" do
      it "returns the job status and percentage" do
        get :export_status, params: { job_id: job_id }, format: :json

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response["status"]).to eq(job_status[:status])
        expect(parsed_response["percentage"]).to eq(percent_complete)
      end
    end
  end

  describe "GET #export_download" do
    let(:job_id) { "job_id" }
    let(:file_path) { Rails.root.join("public", "data", "bookings_#{job_id}.xlsx") }
    before do
      allow(File).to receive(:exist?).with(file_path).and_return(true)
      allow(controller).to receive(:send_file).and_call_original
    end

    context "when format is XLSX" do
      it "sends the XLSX file" do
        get :export_download, params: { job_id: job_id }, format: :xlsx

        expect(response).to have_http_status(:ok)
        expect(controller).to have_received(:send_file).with(file_path)
      end
    end
  end
end
