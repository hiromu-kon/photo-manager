require "test_helper"

class PhotosIndexTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    Photo.delete_all
    User.delete_all

    @user = User.create!(
      email: "user1@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @other_user = User.create!(
      email: "user2@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @older_photo = @user.photos.create!(title: "古い写真")
    @older_photo.image.attach(fixture_file_upload("test.png", "image/png"))

    @newer_photo = @user.photos.create!(title: "新しい写真")
    @newer_photo.image.attach(fixture_file_upload("test.png", "image/png"))

    other_photo = @other_user.photos.create!(title: "他ユーザー写真")
    other_photo.image.attach(fixture_file_upload("test.png", "image/png"))
  end

  test "ログイン中ユーザーの写真だけが新しい順で表示される" do
    post login_path, params: { email: "user1@example.com", password: "password123" }
    follow_redirect!

    assert_response :success
    assert_includes response.body, "新しい写真"
    assert_includes response.body, "古い写真"
    refute_includes response.body, "他ユーザー写真"

    assert_operator response.body.index("新しい写真"), :<, response.body.index("古い写真")
  end

  test "写真一覧に必要なリンクが表示される" do
    post login_path, params: { email: "user1@example.com", password: "password123" }
    follow_redirect!

    assert_includes response.body, "写真アップロード画面へ"
    assert_includes response.body, "ログアウト"
  end
end
