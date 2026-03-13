FactoryBot.define do
  factory :known_server do
    sequence(:domain) { |n| "server#{n}.example" }
    reachable { true }
  end
end
