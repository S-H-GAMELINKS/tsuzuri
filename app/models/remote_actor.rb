class RemoteActor < ApplicationRecord
  has_many :followers, dependent: :destroy
  has_many :inbound_activities, dependent: :nullify

  validates :actor_uri, presence: true, uniqueness: true
  validates :inbox_url, presence: true
  validates :domain, presence: true
end
