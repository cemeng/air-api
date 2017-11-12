require 'resolv'
# RequestGuard checks whether an IP address shall be allowed to access
# an API endpoint.
# An IP address is allowed access to an IP address when
# it request counts < RequestGuard::ALLOWED_REQUESTS within RequestGuard::EXPIRY
# The main method of this class is allow_for?
class RequestGuard
  EXPIRY = 1.hour
  ALLOWED_REQUESTS = 100

  # @params ip [String]. The IP address of the requester. If invalid IP address is supplied, an IPAddressInvalid error
  #   will be thrown.
  # @params method [String]. The request method, valid methods are: GET, POST, PUT, PATCH, DELETE.
  # @params endpoint [String]. This the endpoint to be protected. The param is optional,
  #   when it is not supplied, it means request by an IP will be cumulatively counted
  #   for all endpoints.
  def self.allow_for?(ip:, method: nil, endpoint: nil)
    validate_ip_address!(ip)
    data_store = RequestCounterDataStore.instance
    request_counter = data_store.find_or_create(ip: ip, method: method, endpoint: endpoint, expiry: EXPIRY)
    request_counter.increment
    request_counter.count < ALLOWED_REQUESTS
  end

  class IPAddressInvalidError < StandardError
  end

  def self.validate_ip_address!(ip)
    raise IPAddressInvalidError unless Resolv::IPv4::Regex.match?(ip)
  end
  private_class_method :validate_ip_address!
end
