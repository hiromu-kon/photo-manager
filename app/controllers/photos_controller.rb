require "net/http"
require "json"

class PhotosController < ApplicationController
  before_action :require_login

  TWEET_API_URL = "http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/api/tweets".freeze

  def index
    @photos = current_user.photos.order(created_at: :desc)
  end

  def new
    @errors = []
    @title = ""
  end

  def create
    @title = params.dig(:photo, :title).to_s
    uploaded_image = params.dig(:photo, :image)
    @errors = []

    @errors << "タイトルを入力してください" if @title.blank?
    @errors << "タイトルは30文字以内で入力してください" if @title.length > 30
    @errors << "画像ファイルを入力してください" if uploaded_image.blank?

    if @errors.any?
      return render :new, status: :unprocessable_entity
    end

    photo = current_user.photos.new(title: @title)
    photo.image.attach(uploaded_image)
    photo.save!

    redirect_to photos_path
  end

  def tweet
    photo = current_user.photos.find(params[:id])
    access_token = session[:oauth_access_token].to_s
    if access_token.blank?
      flash[:alert] = "OAuth連携が必要です"
      return redirect_to photos_path
    end
    unless photo.image.attached?
      flash[:alert] = "画像が見つからないためツイートできません"
      return redirect_to photos_path
    end

    uri = URI.parse(TWEET_API_URL)
    payload = {
      text: photo.title,
      url: url_for(photo.image)
    }
    body = payload.to_json
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{access_token}"
    }

    response = Net::HTTP.post(uri, body, headers)
    if response.code.to_i == 201
      flash[:notice] = "ツイートしました"
    else
      flash[:alert] = "ツイートに失敗しました (status: #{response.code})"
    end
    redirect_to photos_path
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "写真が見つかりません"
    redirect_to photos_path
  rescue StandardError
    flash[:alert] = "ツイートに失敗しました"
    redirect_to photos_path
  end
end
