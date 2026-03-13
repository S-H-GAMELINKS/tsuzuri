FactoryBot.define do
  factory :outbound_activity do
    account
    activity_type { "Create" }
    sequence(:activity_uri) { |n| "#{Tsuzuri.base_url}/posts/test-#{n}#create" }
    payload_json { { type: "Create" }.to_json }
    status { "pending" }
  end
end
