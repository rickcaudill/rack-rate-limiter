# Rack::RateLimiter

A Simple Rack middleware for Rack. This should be compatible
with any rack capable framework. For example:

1. Agoo
2. Falcon
3. Iodine
4. NGINX Unit
5. Phusion Passenger (which is mod_rack for Apache and for nginx)
6. Puma
7. Thin
8. Unicorn
9. uWSGI
10. Lamby (AWS Lambda)

This was a PoC designed for fun over a weekend project

# How do I configure

    Rack::RateLimiter.configure do |config|
      config.whitelist("10.0.0.1")
      config.blacklist("192.168.1.1")
      config.rate(ip = "127.0.0.1", count = 2, duration = 1.second)
      config.rate(ip = "10.0.0.1", count = 2, duration = 1.second)
      config.rate(ip = "192.168.1.1", count = 2, duration = 1.second)
      config.logger = ::Logger.new(STDOUT)
      config.log_level = ::Logger::INFO
      config.limited_block = Proc.new { [429, {}, ["Too Many Requests"]] }
      config.blacklisted_block = Proc.new { [403, {}, ["Blacklisted"]] }
    end

# TODO

1. Move Rack::RateLimiter::Limiter#limits to a Cache like memcached and add auto expiry
2. Add a way to clear IPs from cache
3. Add a way to add configuration dynamically
4. Add a way to print out the rules in a readable format
5. Add integrations (Like Slack / AWS SNS / etc)
6. Fix docker image (broken because local gem is used)

# TESTS

Run tests with ```bundle exec rake spec```

