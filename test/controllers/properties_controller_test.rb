require "test_helper"

class PropertiesControllerTest < ActionDispatch::IntegrationTest
  test "index lists active properties" do
    get root_path
    assert_response :success
    assert_select "td", text: properties(:harborview).name
  end

  test "activity shows recent check-ins for the property" do
    get property_activity_path(properties(:harborview).slug)
    assert_response :success
    assert_select "code", text: check_ins(:maya_coat).claim_code
  end

  test "activity raises for an unknown slug" do
    assert_raises(ActiveRecord::RecordNotFound) do
      get property_activity_path("nowhere-inn")
    end
  end

  test "edit renders the settings form" do
    get edit_property_path(properties(:harborview).slug)
    assert_response :success
    assert_select "form"
  end

  test "update saves settings and redirects to activity" do
    property = properties(:harborview)

    patch property_path(property.slug), params: { property: { name: "Harborview Grand Hotel" } }

    assert_redirected_to property_activity_path(property.slug)
    assert_equal "Harborview Grand Hotel", property.reload.name
  end

  test "update saves quiet hours" do
    property = properties(:harborview)

    patch property_path(property.slug),
          params: { property: { quiet_hours_start: "22:00", quiet_hours_end: "07:00" } }

    assert_redirected_to property_activity_path(property.slug)
    property.reload
    assert_equal "22:00", property.quiet_hours_start.strftime("%H:%M")
    assert_equal "07:00", property.quiet_hours_end.strftime("%H:%M")
  end

  test "update rejects an invalid time zone" do
    property = properties(:harborview)

    patch property_path(property.slug), params: { property: { time_zone: "Nope/Nowhere" } }

    assert_response :unprocessable_entity
    assert_equal "America/New_York", property.reload.time_zone
  end
end
