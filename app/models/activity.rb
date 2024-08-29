class Activity < PublicActivity::Activity
  scope :recent_for_user, lambda {|user|
    where(owner: user).order(created_at: :desc) if user.present?
  }
end
