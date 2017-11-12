require 'test_helper'
require 'minitest/autorun'

class HomeControllerTest < ActionController::TestCase
  extend Minitest::Spec::DSL

  def setup
    @controller = HomeController.new
  end

  describe '#index' do
    after { RequestCounter.delete_all }
    describe 'when request from an IP is below the rate limit' do
      it 'returns status 200' do
        get :index
        assert_response 200
      end
    end

    describe 'when request from an IP has exceeded the rate limit' do
      it 'returns status 429' do
        # FIXME - this is slow, need to work out stubbing with minitest,
        # in Rspec - it would be something like: allow_any_instance_of(RequestLimit).to receive(:exceeded?).and_return true
        RequestLimit::ALLOWED_REQUESTS.times { get :index }
        get :index
        assert_response 429
      end
    end
  end
end
