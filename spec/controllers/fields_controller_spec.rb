require "rails_helper"

RSpec.describe FieldsController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, role: :admin) }
  let(:field) { FactoryBot.create(:field) }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "assigns @fields and renders the index template" do
      get :index
      expect(assigns(:fields)).to_not be_nil
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "assigns @field and renders the show template" do
      get :show, params: { id: field.id }
      expect(assigns(:field)).to eq(field)
      expect(response).to render_template(:show)
    end

    it "redirects to fields_path if the field is not found" do
      get :show, params: { id: 0 }
      expect(response).to redirect_to fields_path
      expect(flash[:danger]).to include(I18n.t("fields.show.field_not_found"))
    end
  end

  describe "POST #favorite" do
    context "when favoriting a field successfully" do
      it "creates a favorite and sets the success flash message" do
        post :favorite, params: { id: field.id }, format: :turbo_stream
        expect(user.favorites.exists?(favoritable: field)).to be true
        expect(flash[:success]).to include(I18n.t("fields.favorites.favorite_added"))
      end
    end

    context "when favoriting a field fails" do
      before do
        allow_any_instance_of(Favorite).to receive(:save).and_return(false)
      end

      it "sets the danger flash message and redirects" do
        post :favorite, params: { id: field.id }, format: :html
        expect(flash[:danger]).to include(I18n.t("fields.favorites.favorite_failed"))
        expect(response).to redirect_to(fields_path)
      end
    end

    context "when admin tries to favorite a field" do
      before do
        sign_out user
        sign_in admin
      end

      it "does not allow the admin to favorite a field" do
        post :favorite, params: { id: field.id }, format: :html
        expect(flash[:alert]).to include(I18n.t("authenticate.not_allowed"))
        expect(response).to redirect_to fields_path
      end
    end
  end

  describe "DELETE #unfavorite" do
    let!(:favorite) { user.favorites.create(favoritable: field) }

    context "when unfavoriting a field successfully" do
      it "removes the favorite and sets the success flash message" do
        delete :unfavorite, params: { id: field.id }, format: :turbo_stream
        expect(user.favorites.exists?(favoritable: field)).to be false
        expect(flash[:success]).to include(I18n.t("fields.favorites.favorite_removed"))
      end
    end

    context "when unfavoriting a field fails" do
      before do
        allow_any_instance_of(Favorite).to receive(:destroy).and_return(false)
      end

      it "sets the danger flash message and redirects" do
        delete :unfavorite, params: { id: field.id }, format: :html
        expect(flash[:danger]).to include(I18n.t("fields.favorites.favorite_remove_failed"))
        expect(response).to redirect_to fields_path
      end
    end

    context "when admin tries to unfavorite a field" do
      before do
        sign_out user
        sign_in admin
      end

      it "does not allow the admin to unfavorite a field" do
        delete :unfavorite, params: { id: field.id }, format: :html
        expect(flash[:alert]).to include(I18n.t("authenticate.not_allowed"))
        expect(response).to redirect_to fields_path
      end
    end
  end
end
