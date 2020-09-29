require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'pry' if development?
require 'sinatra/activerecord'
require './models.rb'

require "google/apis/slides_v1"
require "googleauth"
require "googleauth/stores/file_token_store"
require "fileutils"

OOB_URI = "urn:ietf:wg:oauth:2.0:oob".freeze
APPLICATION_NAME = "Google Slides API Ruby Quickstart".freeze
CREDENTIALS_PATH = "credentials.json".freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
TOKEN_PATH = "token.yaml".freeze
SCOPE = Google::Apis::SlidesV1::AUTH_PRESENTATIONS_READONLY

# API KEY
# 'AIzaSyDpZO6Qf1fFRygWLefiNKjwvIj4luIq-W0'

# google slide api
## Client ID
### 375926303724-iu16hqbq46hudgp046rh461t4j582nc3.apps.googleusercontent.com
## Client Secrete
### 2Zi8y4U5fKzAXdqP9tVCTXqJ

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

get '/' do
  if !current_user.nil?
    @scripts = Script.where(user_id: current_user.id)
    p '----------' + Script.where(user_id: current_user.id)[0].to_s
  end
  erb :index
end

get '/signup' do
  erb :sign_up
end

post '/signup' do
  user = User.create(
    name: params[:name],
    password: params[:password],
    password_confirmation: params[:password_confirmation]
  )
  if user.persisted?
    session[:user] = user.id
  end
  redirect '/'
end

get '/signout' do
  session[:user] = nil
  redirect '/'
end

get '/signin' do
  erb :sign_in
end

post '/signin' do
  user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end

# post '/getSlide' do
#   if params[:slide_url]
#     url = params[:slide_url]
#     # slide_id = (url.match('/presentation/d/([a-zA-Z0-9-_]+)'))
#     # slide_id = '1DzieWq9aHR5_g_Cpnd5GtFNIfBosuwU9EXx6RwXjXCo'
#     uri = URI('https://slides.googleapis.com/v1/presentations/')
#     uri.query = URI.encode_www_form({
#       presentationId: slide_id
#     })
#     res = Net::HTTP.get_response(uri)
#     json = JSON.parse(res.body)
#     # binding.pry
#   end
#   redirect '/'
# end

post '/newScript' do
  if !current_user.nil?
    ctbt_count = params[:ctbt_count].to_i
    script = Script.create(
      user_id: current_user.id,
      title: params[:title],
      description: params[:description],
      keyword: params[:keyword],
      slides_url: params[:slides_url]
    )
    p '----------saved - script----------'
    ctbt_count.times do |num|
      param_name = 'ctbt_'+ num.to_s
      name = params[param_name]
      ctbt = Contributor.create(
        name: name,
        scripts_id: script.id
      )
      p ctbt.name
      p '----------saved - ctbt----------'
    end
    # binding.pry
  end
  redirect '/'
end

get '/view/:id' do
  @scripts = Script.where(id: params[:id])
  @lines = Line.where(scripts_id: params[:id])
  erb :view
end

get '/edit/:id' do
  @scripts = Script.where(id: params[:id])
  @lines = Line.where(scripts_id: params[:id])
  erb :edit
end