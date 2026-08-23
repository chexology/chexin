require "test_helper"

class PropertyTest < ActiveSupport::TestCase
  test "valid with name, slug, and IANA time zone" do
    property = Property.new(name: "Cedar Inn", slug: "cedar-inn", time_zone: "America/Denver")
    assert_predicate property, :valid?
  end

  test "requires name, slug, and time_zone" do
    property = Property.new
    assert_not property.valid?
    assert_includes property.errors[:name], "can't be blank"
    assert_includes property.errors[:slug], "can't be blank"
    assert_includes property.errors[:time_zone], "can't be blank"
  end

  test "rejects an unknown time zone" do
    property = Property.new(name: "Cedar Inn", slug: "cedar-inn", time_zone: "Mars/Olympus_Mons")
    assert_not property.valid?
    assert_includes property.errors[:time_zone], "is not a valid IANA time zone"
  end

  test "slug must be unique" do
    property = Property.new(name: "Another Harborview", slug: properties(:harborview).slug,
                            time_zone: "America/New_York")
    assert_not property.valid?
    assert_includes property.errors[:slug], "has already been taken"
  end

  test "quiet_now? is true during the quiet window" do
    travel_to Time.utc(2026, 6, 1, 22, 15) do
      assert_predicate properties(:sundial), :quiet_now?
    end
  end

  test "quiet_now? is false outside the quiet window" do
    travel_to Time.utc(2026, 6, 1, 12, 0) do
      assert_not properties(:sundial).quiet_now?
    end
  end

  test "quiet_now? is false when quiet hours are not configured" do
    assert_not properties(:harborview).quiet_now?
  end
end
