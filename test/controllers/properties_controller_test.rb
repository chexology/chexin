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
end
