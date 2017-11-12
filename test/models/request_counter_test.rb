require 'test_helper'
require 'minitest/autorun'

class ReguestCounterTest < ActiveSupport::TestCase
  extend Minitest::Spec::DSL
  include ActiveSupport::Testing::TimeHelpers

  let(:ip) { '200.1.1.1' }
  let(:request_method) { 'GET' }
  let(:endpoint) { '/api/index' }
  let(:expiry) { 1.hour }
  let(:request_counter) do
    RequestCounter.new(ip: ip, method: request_method, endpoint: endpoint, expiry: expiry)
  end

  after { RequestCounter.delete_all }

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
      assert_nil request_counter.increment
    end
  end

  describe '#expires_in_seconds' do
    it 'returns in seconds when will the request counter expire' do
      request_counter
      travel_to(Time.now + 30.minutes) do
        assert_equal 30.minutes.to_i, request_counter.expires_in_seconds
      end
    end
  end

  describe '.delete_all' do
    it 'deletes all request counters' do
      request1 = RequestCounter.new(ip: '127.0.0.1', method: request_method, endpoint: endpoint, expiry: expiry)
      request2 = RequestCounter.new(ip: '127.0.0.2', method: request_method, endpoint: endpoint, expiry: expiry)
      RequestCounter.delete_all
      assert_nil RequestCounterDataStore.instance.read(request1.key)
      assert_nil RequestCounterDataStore.instance.read(request2.key)
    end
  end
end
