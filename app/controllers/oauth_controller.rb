require "net/http"
require "json"

class OauthController < ApplicationController
  before_action :require_login

  AUTH_URL = "http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/authorize".freeze
  TOKEN_URL = "http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/token".freeze
  REDIRECT_URI = "http://localhost:3000/oauth/callback".freeze

  def authorize
    client_id = oauth_client_id

    query = {
      client_id: client_id,
      response_type: "code",
      redirect_uri: REDIRECT_URI,
      scope: "write_tweet"
    }

    redirect_to "#{AUTH_URL}?#{query.to_query}", allow_other_host: true
  end

  def callback
    code = params[:code].to_s
    return redirect_to photos_path if code.blank?

    access_token = fetch_access_token(code: code)
    session[:oauth_access_token] = access_token

    redirect_to photos_path
  rescue JSON::ParserError
    redirect_to photos_path
  rescue StandardError
    redirect_to photos_path
  end

  private

  def fetch_access_token(code:)
    uri = URI.parse(TOKEN_URL)
    response = Net::HTTP.post_form(
      uri,
      code: code,
      client_id: oauth_client_id,
      client_secret: oauth_client_secret,
      redirect_uri: REDIRECT_URI,
      grant_type: "authorization_code"
    )
    raise StandardError unless response.is_a?(Net::HTTPSuccess)

    access_token = JSON.parse(response.body)["access_token"].to_s
    raise StandardError if access_token.blank?

    access_token
  end

  def oauth_client_id
    Rails.application.credentials.dig(:oauth, :client_id) || "dummy_client_id"
  end

  def oauth_client_secret
    Rails.application.credentials.dig(:oauth, :client_secret) || "dummy_client_secret"
  end
end
