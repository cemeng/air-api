# RequestCounterDataStore is the data store that holds RequestCounter entries.
#
# It has similar interface to Rails.cache interface - but only selected methods is
# implemented.
#
# It is currently using ActiveSupport::Cache::MemoryStore for the data store.
class RequestCounterDataStore
  include Singleton
  EXPIRES_AT_KEY_SUFFIX = 'expires_at'.freeze

  def initialize
    @data_store = ActiveSupport::Cache::MemoryStore.new
  end

  def find_or_create(ip:, method:, endpoint:, expiry:)
    RequestCounter.new(ip: ip, method: method, endpoint: endpoint, expiry: expiry)
  end

  def increment(key)
    @data_store.increment(key)
  end

  def read(key)
    @data_store.read(key)
  end

  def create(key, value, expiry)
    @data_store.write(key, value, expires_in: expiry)
    @data_store.write(expires_at_key(key), Time.now + expiry, expires_in: expiry)
  end

  def delete_matched(partial_key)
    @data_store.delete_matched(partial_key)
  end

  def delete(key)
    @data_store.delete(key)
  end

  def expires_at_for(key)
    @data_store.read(expires_at_key(key))
  end

  private

  def expires_at_key(key)
    "#{key}_#{EXPIRES_AT_KEY_SUFFIX}"
  end
end
