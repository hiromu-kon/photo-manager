require "test_helper"

class OAuthCallbackTest < ActionDispatch::IntegrationTest
  setup do
    Photo.delete_all
    User.delete_all

    @user = User.create!(
      email: "user1@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "未ログインでOAuth callbackにアクセスするとログイン画面へ遷移する" do
    get "/oauth/callback", params: { code: "test-code" }

    assert_redirected_to root_path
  end

  test "認可コードありでアクセストークンを取得し写真一覧へ遷移する" do
    post login_path, params: { email: "user1@example.com", password: "password123" }

    with_stubbed_access_token_response do
      get "/oauth/callback", params: { code: "test-code" }
    end

    assert_redirected_to photos_path
  end

  test "認可コードなしでもエラーにならず写真一覧へ遷移する" do
    post login_path, params: { email: "user1@example.com", password: "password123" }

    get "/oauth/callback"

    assert_redirected_to photos_path
  end

  private

  def with_stubbed_access_token_response(token = "stubbed-oauth-value")
    original_method = Net::HTTP.method(:post_form)
    Net::HTTP.define_singleton_method(:post_form) do |_uri, _params|
      response = Net::HTTPOK.new("1.1", "200", "OK")
      response.instance_variable_set(:@read, true)
      response.instance_variable_set(:@body, { access_token: token }.to_json)
      response
    end
    yield
  ensure
    Net::HTTP.define_singleton_method(:post_form, original_method)
  end
end
