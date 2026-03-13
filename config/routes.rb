Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Public blog
  root "posts#index"
  resources :posts, only: [ :index, :show ]

  # WebFinger
  get ".well-known/webfinger", to: "activity_pub/webfinger#show"

  # ActivityPub endpoints
  scope "/users/:username" do
    get "", to: "activity_pub/actors#show", as: :activity_pub_actor
    get "outbox", to: "activity_pub/outboxes#show", as: :activity_pub_outbox
    post "inbox", to: "activity_pub/inboxes#create", as: :activity_pub_inbox
    get "followers", to: "activity_pub/followers#show", as: :activity_pub_followers
  end

  # Admin
  namespace :admin do
    root "dashboard#show"
    resources :posts, except: [ :show ]
    post "posts/:id/publish", to: "posts#publish", as: :publish_post
    post "posts/:id/delete_post", to: "posts#delete_post", as: :delete_post_activity
    resources :followers, only: [ :index, :destroy ]
    resources :inbound_activities, only: [ :index, :show ]
    resource :settings, only: [ :show, :update ]
    resource :self_destruct, only: [ :show, :create ], controller: "self_destruct" do
      post :confirm
    end
  end

  # Mission Control Jobs
  mount MissionControl::Jobs::Engine, at: "/admin/jobs"
end
