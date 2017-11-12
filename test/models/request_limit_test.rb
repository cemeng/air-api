require 'test_helper'
require 'minitest/autorun'

class ReguestLimitTest < ActiveSupport::TestCase
  describe '#exceeded?' do
    let(:ip) { '200.1.1.1' }
    let(:request_method) { 'GET' }
    let(:endpoint) { '/api/index' }

    after { RequestCounter.delete_all }

    describe 'when the number of requests from an IP is below the rate limit' do
      it 'returns false' do
        guard = RequestLimit.new(ip: ip, method: request_method, endpoint: endpoint)
        assert_equal false, guard.exceeded?
      end
    end

    describe 'when the number of requests from an IP exceeds rate limit' do
      it 'returns true' do
        RequestLimit::ALLOWED_REQUESTS.times do
          RequestLimit.new(ip: ip, method: request_method, endpoint: endpoint)
        end
        guard = RequestLimit.new(ip: ip, method: request_method, endpoint: endpoint)
        assert_equal true, guard.exceeded?
      end
    end

    describe 'when an invalid IP address is supplied' do
      it 'raises IPAddressInvalid error' do
        assert_raises RequestLimit::IPAddressInvalidError do
          RequestLimit.new(ip: 'invalid')
        end
      end
    end
  end
end
