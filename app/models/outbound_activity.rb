class OutboundActivity < ApplicationRecord
  belongs_to :post, optional: true
  belongs_to :account

  has_many :delivery_attempts, dependent: :destroy

  validates :activity_type, presence: true, inclusion: { in: %w[Create Delete Accept] }
  validates :activity_uri, presence: true, uniqueness: true
  validates :payload_json, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending delivering delivered failed] }

  scope :pending, -> { where(status: "pending") }

  def payload
    JSON.parse(payload_json)
  end

  def mark_delivering!
    update!(status: "delivering")
  end

  def mark_delivered!
    update!(status: "delivered")
  end

  def mark_failed!
    update!(status: "failed")
  end
end
