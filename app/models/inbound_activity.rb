class InboundActivity < ApplicationRecord
  belongs_to :remote_actor, optional: true

  validates :activity_type, presence: true
  validates :raw_json, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processed rejected failed] }

  scope :pending, -> { where(status: "pending") }

  def parsed_json
    JSON.parse(raw_json)
  end

  def mark_processed!
    update!(status: "processed")
  end

  def mark_rejected!(message = nil)
    update!(status: "rejected", error_message: message)
  end

  def mark_failed!(message = nil)
    update!(status: "failed", error_message: message)
  end
end
