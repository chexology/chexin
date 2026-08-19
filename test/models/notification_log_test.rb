require "test_helper"

class NotificationLogTest < ActiveSupport::TestCase
  test "valid with check_in, channel, and status" do
    log = check_ins(:maya_coat).notification_logs.new(channel: "sms", status: :sent, detail: "sid SM123")
    assert_predicate log, :valid?
  end

  test "requires a channel" do
    log = check_ins(:maya_coat).notification_logs.new(channel: nil, status: :sent)
    assert_not log.valid?
    assert_includes log.errors[:channel], "can't be blank"
  end
end
