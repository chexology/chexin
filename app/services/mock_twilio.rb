module MockTwilio
  # Raised to simulate a transient carrier/API hiccup. Callers are expected
  # to retry, just like they would with the real Twilio client.
  class TransientError < StandardError; end
end
