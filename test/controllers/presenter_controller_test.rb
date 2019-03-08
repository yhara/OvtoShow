require 'test_helper'

class PresenterControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get presenter_index_url
    assert_response :success
  end

end
