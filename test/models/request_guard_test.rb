require 'test_helper'
require 'minitest/autorun'

class ReguestGuardTest < ActiveSupport::TestCase
  describe '#allow_for?' do
    let(:ip) { '200.1.1.1' }
    let(:request_method) { 'GET' }
    let(:endpoint) { '/api/index' }

    after { RequestCounter.delete_all }

    describe 'when the request is below the rate limit' do
      it 'returns true' do
        allowed = RequestGuard.allow_for?(ip: ip, method: request_method, endpoint: endpoint)
        assert_equal true, allowed
      end
    end

    describe 'when the request exceeds rate limit' do
      it 'returns false' do
        RequestGuard::ALLOWED_REQUESTS.times do
          RequestGuard.allow_for?(ip: ip, method: request_method, endpoint: endpoint)
        end
        allowed = RequestGuard.allow_for?(ip: ip, method: request_method, endpoint: endpoint)
        assert_equal false, allowed
      end
    end

    describe 'when an invalid IP address is supplied' do
      it 'raises IPAddressInvalid error' do
        assert_raises RequestGuard::IPAddressInvalidError do
          RequestGuard.allow_for?(ip: 'invalid')
        end
      end
    end
  end
end
