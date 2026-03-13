FactoryBot.define do
  factory :self_destruct_run do
    state { "pending" }
    confirmation_token { SecureRandom.hex(16) }
  end
end
