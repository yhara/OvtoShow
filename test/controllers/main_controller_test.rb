require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get screen" do
    get main_screen_url
    assert_response :success
  end

  test "should get presenter" do
    get main_presenter_url
    assert_response :success
  end

  test "should get atendee" do
    get main_atendee_url
    assert_response :success
  end

end
