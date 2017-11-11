require 'test_helper'
require 'minitest/autorun'

class ReguestCounterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL

  let(:ip) { '200.1.1.1' }
  let(:request_method) { 'GET' }
  let(:endpoint) { '/api/index' }
  let(:expiry) { 1.hour }
  let(:request_counter) do
    RequestCounter.find_or_create(ip: ip,
                                  method: request_method,
                                  endpoint: endpoint,
                                  expiry: expiry)
  end

  after do
    request_counter.delete
  end

  describe '#increment' do
    it 'increments the count of a request' do
      assert_equal 1, request_counter.increment
    end
  end

  describe '#count' do
    it 'returns the count of a request within the expiry period' do
      2.times { request_counter.increment }
      assert_equal 2, request_counter.count
    end
  end

  describe '#delete' do
    it 'deletes the request counter' do
      request_counter.delete
      assert_equal nil, request_counter.increment
    end
  end
end
