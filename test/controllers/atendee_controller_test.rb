require 'test_helper'

class AtendeeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get atendee_index_url
    assert_response :success
  end

end
