# Stand-in for the Twilio REST client so the app runs anywhere with zero
# credentials. It never sends anything; it logs the message and returns a
# fake SID. Roughly 5% of calls raise MockTwilio::TransientError to keep the
# retry path honest.
class MockTwilioClient
  FAILURE_RATE = 0.05

  def self.send_sms(phone_number, body)
    raise MockTwilio::TransientError, "mock carrier timeout" if rand < FAILURE_RATE

    Rails.logger.info("[MockTwilio] SMS to #{phone_number}: #{body}")
    { sid: "SM#{SecureRandom.hex(8)}", to: phone_number, body: body }
  end
end
