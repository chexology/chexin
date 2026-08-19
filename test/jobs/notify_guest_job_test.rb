require "test_helper"

class NotifyGuestJobTest < ActiveJob::TestCase
  setup do
    @check_in = check_ins(:maya_coat)
  end

  test "logs a sent notification on success" do
    fake_response = { sid: "SM_test_123" }

    MockTwilioClient.stub(:send_sms, fake_response) do
      NotifyGuestJob.perform_now(@check_in)
    end

    log = @check_in.notification_logs.last
    assert_equal "sent", log.status
    assert_equal "sms", log.channel
    assert_includes log.detail, "SM_test_123"
  end

  test "retries transient errors and logs failed after the final attempt" do
    always_down = ->(*) { raise MockTwilio::TransientError, "mock carrier timeout" }

    MockTwilioClient.stub(:send_sms, always_down) do
      perform_enqueued_jobs do
        NotifyGuestJob.perform_later(@check_in)
      end
    end

    assert_equal 0, @check_in.notification_logs.sent.count
    log = @check_in.notification_logs.failed.last
    assert_not_nil log
    assert_equal "mock carrier timeout", log.detail
  end
end
