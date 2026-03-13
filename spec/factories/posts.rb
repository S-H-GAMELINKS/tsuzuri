FactoryBot.define do
  factory :post do
    account
    title { Faker::Lorem.sentence }
    plaintext_body { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    state { "draft" }

    trait :published do
      state { "published" }
      published_at { Time.current }
      slug { title.parameterize }

      after(:create) do |post|
        post.update_columns(
          activity_pub_object_uri: "#{Tsuzuri.base_url}/posts/#{post.id}",
          activity_pub_create_activity_uri: "#{Tsuzuri.base_url}/posts/#{post.id}#create"
        )
      end
    end

    trait :deleted do
      state { "deleted" }
      published_at { 1.day.ago }

      after(:create) do |post|
        post.update_columns(
          activity_pub_delete_activity_uri: "#{Tsuzuri.base_url}/posts/#{post.id}#delete-#{SecureRandom.hex(8)}"
        )
      end
    end
  end
end
