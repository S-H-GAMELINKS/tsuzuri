require "rails_helper"

RSpec.describe "Admin Self-Destruct", type: :request do
  let!(:account) { create(:account, username: "me") }

  before do
    post "/login", params: { email: account.email, password: "password123" }
  end

  describe "GET /admin/self_destruct" do
    it "shows self-destruct page" do
      get admin_self_destruct_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/self_destruct" do
    it "creates a pending run" do
      post admin_self_destruct_path
      expect(response).to have_http_status(:redirect)
      expect(SelfDestructRun.last.state).to eq("pending")
    end
  end

  describe "POST /admin/self_destruct/confirm" do
    it "confirms and starts self-destruct" do
      run = create(:self_destruct_run, state: "pending")
      expect {
        post confirm_admin_self_destruct_path, params: { confirmation_token: run.confirmation_token }
      }.to have_enqueued_job(EnqueueSelfDestructDeletesJob)
      expect(run.reload.state).to eq("running")
    end
  end
end
