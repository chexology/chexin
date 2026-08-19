require "test_helper"

class CheckInsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "mark_ready flips status, stamps ready_at, and enqueues the notification" do
    check_in = check_ins(:maya_coat)

    assert_enqueued_with(job: NotifyGuestJob, args: [check_in]) do
      post mark_ready_check_in_path(check_in)
    end

    assert_redirected_to property_activity_path(check_in.property.slug)
    assert_predicate check_in.reload, :ready?
    assert_not_nil check_in.ready_at
  end
end
