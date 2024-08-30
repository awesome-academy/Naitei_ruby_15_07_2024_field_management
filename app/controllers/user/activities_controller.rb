class User::ActivitiesController < ApplicationController
  authorize_resource class: false
  def index
    @pagy, @activities = pagy Activity.recent_for_user(current_user),
                              limit: Settings.user.booking_fields_pagy
  end
end
