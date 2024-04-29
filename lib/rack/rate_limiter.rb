# frozen_string_literal: true

require_relative "rate_limiter/version"
require_relative 'rate_limiter/configuration'

module Rack
  module RateLimiter

    class << self
      # @return [Rack::RateLimiter::Configuration]
      def configuration
        @configuration ||= Rack::RateLimiter::Configuration.new
      end

      # @return [Rack::RateLimiter::Configuration]
      def configure(&block)
        yield(configuration)
      end
    end

  end
end