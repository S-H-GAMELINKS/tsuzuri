module ActivityPub
  class WebfingerController < BaseController
    def show
      resource = params[:resource]
      return head :bad_request unless resource&.start_with?("acct:")

      acct = resource.delete_prefix("acct:")
      username, domain = acct.split("@")

      return head :not_found unless domain == Tsuzuri.domain

      account = Account.find_by(username: username)
      return head :not_found unless account

      render json: WebfingerResource.new(account).to_h,
             content_type: "application/jrd+json"
    end
  end
end
