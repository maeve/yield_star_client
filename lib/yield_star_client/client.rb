require 'savon'

require 'property_methods'
require 'floor_plan_methods'

module YieldStarClient
  # YieldStarClient::Client is the main object for connecting to the YieldStar AppExchange service.
  # The interface strives to be SOAP-agnostic whenever possible; all inputs and outputs are pure ruby 
  # and no knowledge of SOAP is required in order to use the client.
  class Client
    include PropertyMethods
    include FloorPlanMethods

    attr_writer *YieldStarClient::VALID_CONFIG_OPTIONS

    YieldStarClient::VALID_CONFIG_OPTIONS.each do |opt|
      define_method(opt) { get_value(opt) }
    end

    # Initializes the client. All options are truly optional; if the option
    # is not supplied to this method, then it will be set based on the
    # YieldStarClient configuration.
    #
    # @see YieldStarClient.configure
    #
    # @param [Hash] options
    # @option options [String] :username The username for authenticating to the web service.
    # @option options [String] :password The password for authenticating to the web service.
    # @option options [String] :endpoint The address for connecting to the web service.
    # @option options [String] :namespace The XML namespace to use for requests.
    def initialize(options={})
      options.each { |k,v| self.send("#{k}=", v) if self.respond_to?("#{k}=") }
    end

    # Sets up a SOAP client for sending SOAP requests directly.
    # This method is provided publicly as a convenience, but should
    # rarely be used.
    #
    # @return [Savon::Client]
    def soap_client
      Savon::Client.new do
        wsdl.endpoint = self.endpoint.to_s
        wsdl.namespace = self.namespace
        http.auth.basic self.username, self.password
      end
    end

    private
    # Retrieves an attribute's value. If the attribute has not been set
    # on this object, it is retrieved from the global configuration.
    #
    # @see YieldStarClient.configure
    # 
    # @param [Symbol] attribute the name of the attribute
    # @return [String] the value of the attribute
    def get_value(attribute)
      instance_variable_get("@#{attribute}") || YieldStarClient.send(attribute)
    end
  end
end
