class HomeController < ApplicationController
  before_action :allow_or_reject_request, only: [:index]

  def index
    render json: { message: 'OK' }, status: 200
  end

  private

  def allow_or_reject_request
    limit = RequestLimit.new(ip: request.remote_ip)
    if limit.exceeded?
      render json: { message: "Rate limit exceeded. Try again in #{limit.expires_in_seconds} seconds" }, status: 429
    end
  end
end
