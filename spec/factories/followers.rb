FactoryBot.define do
  factory :follower do
    remote_actor
    account
    sequence(:follow_activity_id) { |n| "https://remote.example/activities/follow/#{n}" }
    state { "active" }
  end
end
