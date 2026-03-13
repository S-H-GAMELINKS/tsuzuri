class Follower < ApplicationRecord
  belongs_to :remote_actor
  belongs_to :account

  validates :follow_activity_id, presence: true, uniqueness: true
  validates :state, presence: true, inclusion: { in: %w[active undone] }

  scope :active, -> { where(state: "active") }

  def undo!
    update!(state: "undone", undone_at: Time.current)
  end

  def active?
    state == "active"
  end
end
