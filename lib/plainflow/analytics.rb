require 'plainflow/analytics/defaults'
require 'plainflow/analytics/utils'
require 'plainflow/analytics/version'
require 'plainflow/analytics/client'
require 'plainflow/analytics/worker'
require 'plainflow/analytics/request'
require 'plainflow/analytics/response'
require 'plainflow/analytics/logging'

module Plainflow
  class Analytics
    def initialize options = {}
      Request.stub = options[:stub] if options.has_key?(:stub)
      @client = Plainflow::Analytics::Client.new options
    end

    def method_missing message, *args, &block
      if @client.respond_to? message
        @client.send message, *args, &block
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @client.respond_to?(method_name) || super
    end

    include Logging
  end
end
