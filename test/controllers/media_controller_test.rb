require "test_helper"

class MediaControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get media_create_url
    assert_response :success
  end
end
