FactoryBot.define do
  factory :delivery_attempt do
    outbound_activity
    inbox_url { "https://remote.example/inbox" }
    success { false }
  end
end
