require "test_helper"

class CheckInTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  setup do
    @property = properties(:harborview)
    @guest = guests(:maya)
  end

  test "generates a six-character claim code on create" do
    check_in = @property.check_ins.create!(guest: @guest, item_description: "garment bag")
    assert_match(/\A[A-Z0-9]{6}\z/, check_in.claim_code)
  end

  test "defaults to checked_in status" do
    check_in = @property.check_ins.create!(guest: @guest, item_description: "garment bag")
    assert_predicate check_in, :checked_in?
  end

  test "claim code must be unique within a property" do
    duplicate = @property.check_ins.new(guest: @guest, item_description: "garment bag",
                                        claim_code: check_ins(:maya_coat).claim_code)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:claim_code], "has already been taken"
  end

  test "the same claim code is allowed at a different property" do
    other = properties(:sundial).check_ins.new(guest: guests(:theo), item_description: "parka",
                                               claim_code: check_ins(:maya_coat).claim_code)
    assert_predicate other, :valid?
  end

  test "mark_ready! sets status, ready_at, and enqueues NotifyGuestJob" do
    check_in = check_ins(:maya_coat)

    assert_enqueued_with(job: NotifyGuestJob, args: [check_in]) do
      check_in.mark_ready!
    end

    assert_predicate check_in.reload, :ready?
    assert_not_nil check_in.ready_at
  end
end
