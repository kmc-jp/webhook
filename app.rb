require 'sinatra'
require 'json'
require 'digest/sha2'
require 'net/https'

WH_URI = ENV['SLACK_WH_URI']

def status(str)
  if str == 'Pending'
    return 'started'
  else
    return 'started' + srr
  end
end

def color(status)
  if status == 'Pending' || status == 'Passed'
    return 'good'
  else
    return 'danger'
  end
end

def emoji(status)
  if color(status) == 'danger'
    return ":tohu_on_fire:"
  else
    return ":eye"
  end
end

class Webhook < Sinatra::Base
  set :token, ENV['TRAVIS_USER_TOKEN']

  get '/' do
    "Hello World"
  end

  get '/travis' do
    "hoee"
  end

  post '/travis' do
    p = JSON.parse(params[:payload])
    text = "Build #{p['number']} for #{p['repository']['owner_name']}/#{p['repository']['name']} #{status(p['status_message'])}\n#{p['message']}\n#{p['build_url']}"
    status = p['status_message']

#    text = "hello"
    hash = {
      "fallback" => text,
      "channel" => "#test-command",
      "color" => color(status)
      "icon_emoji" => emoij(status),
      "username" => "Travis CI",
    }.to_json

    hash = "payload=" + hash

    uri = URI.parse(WH_URI)
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.request_uri)
    req.body = hash
    res = https.request(req)
    res.body
#    params[:payload]
  end

  def valid_request?
    digest = Digest::SHA2.new.update("#{repo_slug}#{settings.token}")
    digest.to_s == authorization
  end

  def authorization
    env['HTTP_AUTHORIZATION']
  end

  def repo_slug
    env['HTTP_TRAVIS_REPO_SLUG']
  end
end
