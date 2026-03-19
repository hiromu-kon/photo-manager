require "test_helper"
require "uri"

class OAuthAuthorizeTest < ActionDispatch::IntegrationTest
  setup do
    Photo.delete_all
    User.delete_all

    @user = User.create!(
      email: "user1@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "未ログインでOAuth認可URLにアクセスするとログイン画面へ遷移する" do
    get "/oauth/authorize"

    assert_redirected_to root_path
  end

  test "ログイン後にOAuth認可URLへリダイレクトされる" do
    post login_path, params: { email: "user1@example.com", password: "password123" }

    get "/oauth/authorize"
    assert_response :redirect

    location = response.headers["Location"]
    uri = URI.parse(location)
    params = Rack::Utils.parse_query(uri.query)

    assert_equal "http", uri.scheme
    assert_equal "unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com", uri.host
    assert_equal "/oauth/authorize", uri.path

    expected_client_id = Rails.application.credentials.dig(:oauth, :client_id) || "dummy_client_id"
    assert_equal expected_client_id, params["client_id"]
    assert_equal "code", params["response_type"]
    assert_equal "http://localhost:3000/oauth/callback", params["redirect_uri"]
    assert_equal "write_tweet", params["scope"]
  end
end
