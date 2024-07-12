require "test_helper"

class WeatherControllerTest < ActionDispatch::IntegrationTest
  test "index - can see the root page" do
    get root_path
    assert_select "h1", "Weather Forecast"
    assert_select "#location_zipcode", ""
    assert_select "input[type=submit][value=?]", "Go"
  end

  test "index - empty zipcode returns error message" do
    post root_path,  params: { location: { zipcode: "" } }
    assert_response :unprocessable_entity
    assert_select "p", "Zipcode cannot be blank."
  end

  test "index - invalid zipcode returns error message" do
    post root_path,  params: { location: { zipcode: "00000" } }
    assert_response :unprocessable_entity
    assert_select "p", "Zipcode not found. Please try again."
  end

  test "index - valid zipcode returns success weather forecast" do
    post root_path,  params: { location: { zipcode: "95014" } }
    assert_response :redirect
    follow_redirect!
    assert_equal path, "/forecast"
    assert_select "h2", "Current conditions for Cupertino"
  end

  test "forecast - empty lat and lon values" do
    get forecast_path
    assert_response :redirect
  end

  test "forecast - invalid lat and lon values" do
    get forecast_path,  params: { lat: "invalid", lon: "invalid" }
    assert_response :unprocessable_entity
    assert_select "p", "An error has occured. Contact your system administrator."
  end

  test "forecast - current weather conditions found " do
    get forecast_path,  params: { lat: "37.318", lon: "-122.0449" }
    assert_response :success
    assert_select "h2", "Current conditions for Cupertino"
  end
end
