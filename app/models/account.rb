class Account < ApplicationRecord
  include Rodauth::Rails.model
  enum :status, { unverified: 1, verified: 2, closed: 3 }

  has_many :posts, dependent: :destroy
  has_many :followers, dependent: :destroy
  has_many :outbound_activities, dependent: :destroy

  validates :private_key_pem, presence: true
  validates :public_key_pem, presence: true
  validates :activity_pub_url, presence: true
  validates :username, uniqueness: true, allow_nil: true

  def private_key
    OpenSSL::PKey::RSA.new(private_key_pem)
  end

  def public_key
    OpenSSL::PKey::RSA.new(public_key_pem)
  end

  def key_id
    "#{activity_pub_url}#main-key"
  end

  def username_set?
    username.present?
  end

  def set_username!(new_username)
    raise "Username already set" if username_set?

    update!(
      username: new_username,
      activity_pub_url: "#{Tsuzuri.base_url}/users/#{new_username}"
    )
  end
end
