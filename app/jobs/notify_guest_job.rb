class NotifyGuestJob < ApplicationJob
  queue_as :default

  def perform(check_in)
    # SMS delivery lands in a follow-up; for now this is just the enqueue point.
  end
end
