# RequestCounterDataStore is the data store that holds RequestCounter entries.
#
# It has similar interface to Rails.cache interface - but only selected methods is
# implemented.
#
# It is currently using ActiveSupport::Cache::MemoryStore for the data store.
class RequestCounterDataStore
  include Singleton

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

  def write(key, value, options = {})
    @data_store.write(key, value, options)
  end

  def delete_matched(partial_key)
    @data_store.delete_matched(partial_key)
  end

  def delete(key)
    @data_store.delete(key)
  end
end
