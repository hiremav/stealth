# coding: utf-8
# frozen_string_literal: true

module Stealth

  # Responsible for coordinating incoming messages
  #  1. Receives incoming request params
  #  2. Initializes respective service request handler
  #  3. Processes params through service request handler (might be async)
  #  4. Inits base StealthController with state params returned from the service
  #     request handler
  #  5. Returns an HTTP response to be returned to the requestor
  class Dispatcher

    attr_reader :service, :params, :headers, :request_handler

    def initialize(service:, params:, headers:)
      @service = service
      @params = params
      @headers = headers
      @request_handler = request_handler_klass.new(
        params: params,
        headers: headers
      )
    end

    def coordinate
      request_handler.coordinate
    end

    def process
      service_message = request_handler.process
      bot_controller = BotController.new(service_message: service_message)
      bot_controller.route
    end

    private

      def request_handler_klass
        begin
          Kernel.const_get("Stealth::Services::#{service.capitalize}::MessageHandler")
        rescue NameError
          raise(ServiceNotRecognized, "The service '#{service}' was not recognized.")
        end
      end

  end
end
