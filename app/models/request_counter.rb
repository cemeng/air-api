# RequestCounter represents an entry in RequestCounterDataStore, this entry holds how many time
# a request from an IP address# comes to an API endpoint.
#
# A RequestCounter entry will be cleared after a specified expiry time, the expiry time
# is specified when the entry is created.
class RequestCounter
  KEY_PREFIX = 'request_counter_'.freeze

  def initialize(ip:, method:, endpoint:, expiry:)
    @ip = ip
    @method = method
    @endpoint = endpoint
    create_counter(expiry) unless data_store.read(key)
  end

  def increment
    data_store.increment(key)
  end

  def count
    data_store.read(key)
  end

  def delete
    data_store.delete(key)
  end

  def self.delete_all
    RequestCounterDataStore.instance.delete_matched("#{KEY_PREFIX}*")
  end

  def key
    "#{KEY_PREFIX}_#{@ip}_#{@method}_#{@endpoint}"
  end

  private

  def create_counter(expiry)
    data_store.write(key, 0, expires_in: expiry)
  end

  def data_store
    RequestCounterDataStore.instance
  end
end
