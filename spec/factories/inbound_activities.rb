FactoryBot.define do
  factory :inbound_activity do
    remote_actor
    activity_type { "Follow" }
    raw_json { { type: "Follow", actor: "https://remote.example/users/someone", object: "https://local.example/users/me" }.to_json }
    signature_verified { true }
    status { "pending" }
  end
end
