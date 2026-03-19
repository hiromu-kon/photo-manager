require "test_helper"

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  setup do
    Photo.delete_all
    User.delete_all
    User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "トップページでログイン画面が表示される" do
    get root_path

    assert_response :success
    assert_includes response.body, "ログイン"
  end

  test "メールアドレスの大文字小文字を無視してログインできる" do
    post login_path, params: { email: "TEST@EXAMPLE.COM", password: "password123" }

    assert_redirected_to photos_path

    follow_redirect!
    assert_response :success
    assert_includes response.body, "写真一覧"
  end

  test "メールアドレス未入力でログイン失敗する" do
    post login_path, params: { email: "", password: "password123" }

    assert_response :unprocessable_entity
    assert_includes response.body, "メールアドレスを入力してください"
  end

  test "パスワード未入力でログイン失敗しメールアドレスが保持される" do
    post login_path, params: { email: "test@example.com", password: "" }

    assert_response :unprocessable_entity
    assert_includes response.body, "パスワードを入力してください"
    assert_includes response.body, 'value="test@example.com"'
  end

  test "メールアドレスとパスワードが一致しないとログイン失敗する" do
    post login_path, params: { email: "test@example.com", password: "wrong-password" }

    assert_response :unprocessable_entity
    assert_includes response.body, "メールアドレスまたはパスワードが正しくありません"
  end

  test "未ログインで写真一覧にアクセスするとログイン画面へ遷移する" do
    get photos_path

    assert_redirected_to root_path
  end

  test "ログアウトすると未ログイン状態に戻りログイン画面が表示される" do
    post login_path, params: { email: "test@example.com", password: "password123" }
    assert_redirected_to photos_path

    delete logout_path
    assert_redirected_to root_path

    follow_redirect!
    assert_response :success
    assert_includes response.body, "ログイン"

    get photos_path
    assert_redirected_to root_path
  end
end
