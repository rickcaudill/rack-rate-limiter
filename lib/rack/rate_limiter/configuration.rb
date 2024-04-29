require 'logger'

module Rack
  module RateLimiter
    class Configuration

      attr_accessor :logger
      attr_reader :log_level
      attr_accessor :limited_block
      attr_accessor :blacklisted_block

      def initialize
        @whitelist = []
        @blacklist = []
        @rates = {}
        @logger = ::Logger.new(STDOUT)
        @log_level = ::Logger::INFO
        @limited_block = Proc.new { [429, {}, ["Too Many Requests"]] }
        @blacklisted_block = Proc.new { [403, {}, ["Blacklisted"]] }
      end

      def whitelisted?(ip)
        @whitelist.include?(ip)
      end

      def blacklisted?(ip)
        @blacklist.include?(ip)
      end

      def rate(ip = "", count = 1, duration = 1.second)
        @rates[ip.to_sym] = { count: count, duration: duration }
      end

      def whitelist(ip)
        @whitelist = @whitelist.push(ip)
      end

      def blacklist(ip)
        @blacklist = @blacklist.push(ip)
      end

      def limited?(ip, time, limits)
        rate = @rates[ip.to_sym]
        return false if rate.nil?
        limit = limits.has_key?(ip.to_sym) ? limits[ip.to_sym] || [] : []
        count = ((limit.reject { |l| (time - l) > rate[:duration].seconds.to_i } || [])&.length || 0)
        return count >= rate[:count]
      end
    end
  end
end