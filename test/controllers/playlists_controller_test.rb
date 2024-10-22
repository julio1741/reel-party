require "test_helper"

class PlaylistsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get playlists_create_url
    assert_response :success
  end

  test "should get destroy" do
    get playlists_destroy_url
    assert_response :success
  end
end
