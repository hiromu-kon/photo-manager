class SessionsController < ApplicationController
  def new
    @errors = []
  end

  def create
    @email = params[:email].to_s
    password = params[:password].to_s
    @errors = []

    @errors << "メールアドレスを入力してください" if @email.blank?
    @errors << "パスワードを入力してください" if password.blank?

    if @errors.any?
      return render :new, status: :unprocessable_entity
    end

    user = User.find_by(email: @email.downcase)

    if user&.authenticate(password)
      session[:user_id] = user.id
      redirect_to photos_path
    else
      @errors << "メールアドレスまたはパスワードが正しくありません"
      render :new, status: :unprocessable_entity
    end
  end
end
