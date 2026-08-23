namespace :notifications do
  desc "Re-enqueue guest SMS that were held during quiet hours"
  task flush_held: :environment do
    held = CheckIn.ready
                  .joins(:notification_logs)
                  .where(notification_logs: { status: :skipped })
                  .where.not(id: NotificationLog.sent.select(:check_in_id))
                  .distinct

    held.each do |check_in|
      next if check_in.property.quiet_now?

      NotifyGuestJob.perform_later(check_in)
      puts "Re-enqueued notification for check-in ##{check_in.id} (#{check_in.property.name})"
    end
  end
end
