# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new

    if user.admin?
      admin_permissions
    else
      user_permissions user
    end
  end

  private

  def admin_permissions
    can :manage, :all
    cannot :favorite, Field
    cannot :unfavorite, Field
  end

  def user_permissions user
    cannot_manage_admin_resources
    define_user_permissions user
  end

  def cannot_manage_admin_resources
    cannot :manage, %i(Admin::UsersController
                       Admin::BookingFieldsController
                       Admin::FieldsController
                       Admin::VouchersController)
  end

  def define_user_permissions user
    can :read, BookingField, user_id: user.id
    can %i(update show), User, id: user.id
    can :manage, Address, user_id: user.id
    can :create, BookingField
    can %i(update destroy read index), BookingField, user_id: user.id
    can :manage, Favorite, user_id: user.id
    can %i(favorite unfavorite), Field
    can :manage, Rating, user_id: user.id
    can :manage, Comment, user_id: user.id
    can :manage, Timeline, user_id: user.id
  end
end
