require 'rack/rate_limiter'
Rack::RateLimiter.configure do |config|
  config.whitelist("10.0.0.1")
  config.blacklist("192.168.1.1")
  config.rate(ip = "127.0.0.1", count = 2, duration = 1.second)
  config.rate(ip = "10.0.0.1", count = 2, duration = 1.second)
  config.rate(ip = "192.168.1.1", count = 2, duration = 1.second)
  config.logger = Rails.logger
  config.limited_block = Proc.new {
    html = ActionView::Base.empty.render(file: 'public/429.html')
    [429, { 'Content-Type' => 'text/html' }, [html]]
  }
end