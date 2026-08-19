require "test_helper"

class GuestTest < ActiveSupport::TestCase
  test "valid with property, name, and phone number" do
    guest = properties(:harborview).guests.new(name: "Sam Field", phone_number: "+15550107777")
    assert_predicate guest, :valid?
  end

  test "requires name and phone number" do
    guest = properties(:harborview).guests.new
    assert_not guest.valid?
    assert_includes guest.errors[:name], "can't be blank"
    assert_includes guest.errors[:phone_number], "can't be blank"
  end
end
