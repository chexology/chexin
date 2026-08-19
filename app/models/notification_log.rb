class NotificationLog < ApplicationRecord
  belongs_to :check_in

  enum status: { sent: "sent", failed: "failed", skipped: "skipped" }

  validates :channel, presence: true
end
