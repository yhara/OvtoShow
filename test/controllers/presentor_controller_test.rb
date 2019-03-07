require 'test_helper'

class PresentorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get presentor_index_url
    assert_response :success
  end

end
