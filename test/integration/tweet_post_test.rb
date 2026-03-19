require "test_helper"
require "json"

class TweetPostTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    Photo.delete_all
    User.delete_all

    @user = User.create!(
      email: "user1@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @photo = @user.photos.create!(title: "テスト画像")
    @photo.image.attach(fixture_file_upload("test.png", "image/png"))
  end

  test "未ログインでツイート投稿にアクセスするとログイン画面へ遷移する" do
    post tweet_photo_path(@photo)

    assert_redirected_to root_path
  end

  test "アクセストークン未設定時はAPIを呼ばずに写真一覧へ遷移する" do
    post login_path, params: { email: "user1@example.com", password: "password123" }

    original_post = Net::HTTP.method(:post)
    Net::HTTP.define_singleton_method(:post) do |_uri, _data, _headers|
      raise "API should not be called"
    end

    begin
      post tweet_photo_path(@photo)
    ensure
      Net::HTTP.define_singleton_method(:post, original_post)
    end

    assert_redirected_to photos_path
  end

  test "アクセストークン設定時にツイートAPIを呼び出してフラッシュを表示する" do
    post login_path, params: { email: "user1@example.com", password: "password123" }

    with_stubbed_access_token_response do
      get "/oauth/callback", params: { code: "test-code" }
    end

    captured_uri = nil
    captured_body = nil
    captured_headers = nil

    original_post = Net::HTTP.method(:post)
    Net::HTTP.define_singleton_method(:post) do |uri, data, headers|
      captured_uri = uri
      captured_body = data
      captured_headers = headers
      Net::HTTPCreated.new("1.1", "201", "Created")
    end

    begin
      post tweet_photo_path(@photo)
    ensure
      Net::HTTP.define_singleton_method(:post, original_post)
    end

    assert_redirected_to photos_path
    assert_equal "http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/api/tweets", captured_uri.to_s
    assert_equal "application/json", captured_headers["Content-Type"]
    assert_equal "Bearer stubbed-oauth-value", captured_headers["Authorization"]

    payload = JSON.parse(captured_body)
    assert_equal "テスト画像", payload["text"]
    assert_match(%r{\Ahttps?://}, payload["url"])
    assert_includes payload["url"], "/rails/active_storage/"

    follow_redirect!
    assert_response :success
    assert_includes response.body, "ツイートしました"
    assert_includes response.body, "ログアウト"
  end

  test "アクセストークン設定時は写真一覧にツイートするボタンが表示される" do
    post login_path, params: { email: "user1@example.com", password: "password123" }

    with_stubbed_access_token_response do
      get "/oauth/callback", params: { code: "test-code" }
      follow_redirect!
    end

    assert_response :success
    assert_includes response.body, "ツイートする"
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
