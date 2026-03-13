class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :check_read_only_mode

  private

  def check_read_only_mode
    return unless request.post? || request.patch? || request.put? || request.delete?

    run = SelfDestructRun.last
    return unless run&.running_or_draining?

    # Allow inbox POST (ActivityPub) and self-destruct management
    return if request.path.start_with?("/users/") && request.path.end_with?("/inbox")
    return if request.path.start_with?("/admin/self_destruct")

    render plain: "Service is shutting down", status: :service_unavailable
  end
end
