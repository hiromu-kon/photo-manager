class PhotosController < ApplicationController
  before_action :require_login

  def index
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
end
