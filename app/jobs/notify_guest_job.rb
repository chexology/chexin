class NotifyGuestJob < ApplicationJob
  queue_as :default

  # Transient carrier errors are retried a couple of times; if the final
  # attempt still fails we record it so the dashboard shows what happened.
  retry_on MockTwilio::TransientError, wait: 5.seconds, attempts: 3 do |job, error|
    check_in = job.arguments.first
    check_in.notification_logs.create!(channel: "sms", status: :failed, detail: error.message)
  end

  def perform(check_in)
    if check_in.property.quiet_now?
      check_in.notification_logs.create!(channel: "sms", status: :skipped, detail: "quiet hours")
      return
    end

    guest = check_in.guest
    body = "Hi #{guest.name}, your #{check_in.item_description} is ready for pickup at " \
           "#{check_in.property.name}. Claim code: #{check_in.claim_code}."

    response = MockTwilioClient.send_sms(guest.phone_number, body)
    check_in.notification_logs.create!(channel: "sms", status: :sent, detail: "sid #{response[:sid]}")
  end
end
