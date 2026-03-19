require "test_helper"

class PhotoUploadTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  setup do
    Photo.delete_all
    User.delete_all

    @user = User.create!(
      email: "user1@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post login_path, params: { email: "user1@example.com", password: "password123" }
    follow_redirect!
  end

  test "タイトルと画像ファイルを指定してアップロードできる" do
    assert_difference("Photo.count", 1) do
      post photos_path, params: {
        photo: {
          title: "テスト画像",
          image: fixture_file_upload("test.png", "image/png")
        }
      }
    end

    assert_redirected_to photos_path
    follow_redirect!
    assert_includes response.body, "テスト画像"
  end

  test "タイトル未入力でエラーになる" do
    post photos_path, params: {
      photo: {
        title: "",
        image: fixture_file_upload("test.png", "image/png")
      }
    }

    assert_response :unprocessable_entity
    assert_includes response.body, "タイトルを入力してください"
  end

  test "画像未入力でエラーになる" do
    post photos_path, params: {
      photo: {
        title: "テスト画像",
        image: nil
      }
    }

    assert_response :unprocessable_entity
    assert_includes response.body, "画像ファイルを入力してください"
  end

  test "タイトルが30文字超過でエラーになる" do
    post photos_path, params: {
      photo: {
        title: "あ" * 31,
        image: fixture_file_upload("test.png", "image/png")
      }
    }

    assert_response :unprocessable_entity
    assert_includes response.body, "タイトルは30文字以内で入力してください"
  end
end
