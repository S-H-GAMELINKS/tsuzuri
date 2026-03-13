module Admin
  class SelfDestructController < BaseController
    def show
      @run = SelfDestructRun.last
      @plan = Tsuzuri::SelfDestructPlan.new if @run.nil? || @run.completed?
    end

    def create
      token = SecureRandom.hex(16)
      @run = SelfDestructRun.create!(
        state: "pending",
        confirmation_token: token
      )
      redirect_to admin_self_destruct_path, notice: "Self-destruct initiated. Please confirm."
    end

    def confirm
      @run = SelfDestructRun.last
      return redirect_to admin_self_destruct_path, alert: "No pending self-destruct." unless @run

      @run.confirm!(params[:confirmation_token])
      Tsuzuri::SelfDestructRunner.new(@run).execute!

      redirect_to admin_self_destruct_path, notice: "Self-destruct confirmed and running."
    rescue RuntimeError => e
      redirect_to admin_self_destruct_path, alert: e.message
    end
  end
end
