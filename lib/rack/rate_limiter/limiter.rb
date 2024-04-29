require 'net/http'
require 'rack/rate_limiter/configuration'
module Rack
  module RateLimiter

    class Limiter
      attr_reader :app

      def initialize(app, options = {})
        @app = app
        @limits = {}
        @configuration = Rack::RateLimiter.configuration
      end

      def call(env)
        request = Request.new(env)
        time = Time.now.to_i

        if @configuration.whitelisted?(request.ip)
          @app.call(env)
        elsif @configuration.blacklisted?(request.ip)
          @configuration.blacklisted_block.call
        elsif @configuration.limited?(request.ip, time, @limits)
          @configuration.logger.add(@configuration.log_level, "=== Rate Exceeded: #{request.ip} - #{Time.at(time)} ===")
          @configuration.limited_block.call
        else
          @limits[request.ip.to_sym] = @limits.has_key?(request.ip.to_sym) ? (@limits[request.ip.to_sym] || []).unshift(time) : [time]
          @app.call(env)
        end
      end
    end
  end
end