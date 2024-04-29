# frozen_string_literal: true

require "rack/test"
require 'rack/rate_limiter'
require 'rack'
require 'active_support/core_ext/integer/time'
require 'rack/rate_limiter/limiter'

RSpec.describe Rack::RateLimiter do
  include Rack::Test::Methods

  before(:all) do
    Rack::RateLimiter.configure do |config|
      config.whitelist("10.0.0.1")
      config.blacklist("192.168.1.1")
      config.rate(ip = "127.0.0.1", count = 2, duration = 1.second)
      config.rate(ip = "10.0.0.1", count = 2, duration = 1.second)
      config.rate(ip = "192.168.1.1", count = 2, duration = 1.second)
    end
  end

  it("one request in 1 second should return 200 ") {
    app = Rack::Builder.new do
      use Rack::RateLimiter::Limiter
      run lambda { |env| [200, { 'content-type' => 'text/plain' }, ['hello']] }
    end.to_app

    req = Rack::MockRequest.new(app)
    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    expect(res.status).to eq(200)
  }

  it("two requests in 1 second should return 200") {

    sleep 2
    app = Rack::Builder.new do
      use Rack::RateLimiter::Limiter
      run lambda { |env| [200, { 'content-type' => 'text/plain' }, ['hello']] }
    end.to_app

    req = Rack::MockRequest.new(app)
    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    expect(res.status).to eq(200)
  }

  it("two requests in 1 second should return rate limited for third request") {
    sleep 2

    app = Rack::Builder.new do
      use Rack::RateLimiter::Limiter
      run lambda { |env| [200, { 'content-type' => 'text/plain' }, ['hello']] }
    end.to_app

    req = Rack::MockRequest.new(app)

    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")

    expect(res.status).to eq(429)
  }

  it("two requests in 1 second should return rate limited, sleep 2 seconds and third request should be alloed") {
    sleep 2
    app = Rack::Builder.new do
      use Rack::RateLimiter::Limiter
      run lambda { |env| [200, { 'content-type' => 'text/plain' }, ['hello']] }
    end.to_app

    req = Rack::MockRequest.new(app)

    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    sleep 2

    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    expect(res.status).to eq(200)
  }

  it("two requests in 1 second should return rate limited, sleep 2 seconds and sixth request should be alloed") {
    sleep 2
    app = Rack::Builder.new do
      use Rack::RateLimiter::Limiter
      run lambda { |env| [200, { 'content-type' => 'text/plain' }, ['hello']] }
    end.to_app

    req = Rack::MockRequest.new(app)

    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")

    sleep 2

    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "127.0.0.1")

    expect(res.status).to eq(429)
  }

  it("should whitelist 10.0.0.1") do
    app = Rack::Builder.new do
      use Rack::RateLimiter::Limiter
      run lambda { |env| [200, { 'content-type' => 'text/plain' }, ['hello']] }
    end.to_app

    req = Rack::MockRequest.new(app)

    res = req.get('/', "REMOTE_ADDR" => "10.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "10.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "10.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "10.0.0.1")
    res = req.get('/', "REMOTE_ADDR" => "10.0.0.1")

    expect(res.status).to eq(200)
  end

  it("should blacklist 192.168.1.1") do
    app = Rack::Builder.new do
      use Rack::RateLimiter::Limiter
      run lambda { |env| [200, { 'content-type' => 'text/plain' }, ['hello']] }
    end.to_app

    req = Rack::MockRequest.new(app)

    res = req.get('/', "REMOTE_ADDR" => "192.168.1.1")
    res = req.get('/', "REMOTE_ADDR" => "192.168.1.1")
    res = req.get('/', "REMOTE_ADDR" => "192.168.1.1")

    expect(res.status).to eq(403)
  end
end
