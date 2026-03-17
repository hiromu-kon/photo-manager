class OauthController < ApplicationController
  before_action :require_login

  AUTH_URL = "http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/authorize".freeze
  REDIRECT_URI = "http://localhost:3000/oauth/callback".freeze

  def authorize
    client_id = Rails.application.credentials.dig(:oauth, :client_id) || "dummy_client_id"

    query = {
      client_id: client_id,
      response_type: "code",
      redirect_uri: REDIRECT_URI,
      scope: "write_tweet"
    }

    redirect_to "#{AUTH_URL}?#{query.to_query}", allow_other_host: true
  end
end
