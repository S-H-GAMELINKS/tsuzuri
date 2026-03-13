class KnownServer < ApplicationRecord
  validates :domain, presence: true, uniqueness: true

  scope :reachable, -> { where(reachable: true) }

  def touch_last_seen!
    update!(last_seen_at: Time.current)
  end

  def mark_unreachable!
    update!(reachable: false)
  end
end
