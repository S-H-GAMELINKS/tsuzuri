class DeliveryAttempt < ApplicationRecord
  belongs_to :outbound_activity

  validates :inbox_url, presence: true
end
