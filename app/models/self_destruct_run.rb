class SelfDestructRun < ApplicationRecord
  STATES = %w[pending confirmed running draining completed shutdown].freeze

  validates :state, presence: true, inclusion: { in: STATES }

  def confirm!(token)
    raise "Invalid token" unless confirmation_token == token

    update!(state: "confirmed")
  end

  def start!
    update!(state: "running", started_at: Time.current, read_only_at: Time.current)
  end

  def drain!
    update!(state: "draining")
  end

  def complete!
    update!(state: "completed", completed_at: Time.current)
  end

  def shutdown!
    update!(state: "shutdown")
  end

  def running_or_draining?
    state.in?(%w[running draining])
  end

  def completed?
    state == "completed"
  end

  def progress_percentage
    return 0 if total_activities.zero?

    ((delivered_activities + failed_activities).to_f / total_activities * 100).round(1)
  end
end
