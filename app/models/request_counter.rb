# RequestCounter is a data store that captures how many time a request from an IP address
# comes to an API endpoint. The request counter will be cleared after the specified expiry time.
#
# The public method for this class is .find_or_create.
# Example:
#   RequestCounter.find_or_create(ip: '127.0.0.1', method: 'GET', endpoint: '/', expiry: 3600)
class RequestCounter
  # A factory method
  def self.find_or_create(ip:, method:, endpoint:, expiry:)
    new(ip: ip, method: method, endpoint: endpoint, expiry: expiry)
  end

  def initialize(ip:, method:, endpoint:, expiry:)
    @ip = ip
    @method = method
    @endpoint = endpoint
    create_counter(expiry) unless datastore.read(counter_cache_key)
  end

  def increment
    datastore.increment(counter_cache_key)
  end

  def count
    datastore.read(counter_cache_key)
  end

  def delete
    datastore.delete(counter_cache_key)
  end

  private

  def create_counter(expiry)
    datastore.write(counter_cache_key, 0, expires_in: expiry)
  end

  def datastore
    Rails.cache
  end

  def cache_key_prefix
    "#{@ip}_#{@method}_#{@endpoint}"
  end

  def counter_cache_key
    "#{cache_key_prefix}_counter"
  end
end
