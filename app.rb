require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'pry' if development?
require 'sinatra/activerecord'
require './models.rb'
require './googleslide.rb'
require 'dotenv/load'

service = Google::Apis::SlidesV1::SlidesService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

enable :sessions

before do
  Dotenv.load
end

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

get '/' do
  if !current_user.nil?
    @scripts = Script.where(user_id: current_user.id)
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

post '/getSlide' do
  if params[:slide_url]
    url = params[:slide_url]
    presentation_id = getPresentationId(url)
  end
  redirect '/'
end

get '/newScript' do
  if !current_user.nil?
    erb :new_script
  elsif
    redirect '/'
  end
end

post '/newScript' do
  if !current_user.nil?
    ctbt_arr = []
    url = params[:presentation_url]
    presentation_id = getPresentationId(url)
    ctbt_original = params[:ctbt]
    ctbt_arr = ctbt_original.split(/,/,)
    # binding.pry
    script = Script.create!(
      user_id: current_user.id,
      title: params[:title],
      description: params[:description],
      keyword: params[:keyword],
      presentation_id: presentation_id
    )
    ctbt_arr.each do |ctbt|
      contributor = Contributor.create!(
        name: ctbt,
        scripts_id: script.id
      )
    end
    # # get presentation slide count
    presentation = service.get_presentation(script.presentation_id)
    thumbnails = Array[]
    # # create lines for each slides
    presentation.slides.each_with_index do |page, i|
      thumbnails.push(service.get_presentation_page_thumbnail(
        script.presentation_id,
        page.object_id_prop,
        thumbnail_properties_thumbnail_size: 'SMALL')
        .content_url)
      line = Line.create!(
        scripts_id: script.id,
        contributors_id: Contributor.where(scripts_id: script.id).first.id,
        order_num: i,
        thumbnail_url: thumbnails[i],
        body: ""
      )
    end
  end
  redirect "/view/#{script.id}"
end

get '/view/:id' do
  @script = Script.where(id: params[:id]).first
  @lines = Line.where(scripts_id: params[:id])
  @contributors = Contributor.where(scripts_id: params[:id])
  @presentation = service.get_presentation(@script.presentation_id)
  @thumbnails = Array[]
  @presentation.slides.each_with_index do |slide, i|
    @thumbnails.push(service.get_presentation_page_thumbnail(
      @script.presentation_id,
      slide.object_id_prop,
      thumbnail_properties_thumbnail_size: 'SMALL')
      .content_url)
  end
  erb :view
end

get '/edit/:id' do
  @script = Script.where(id: params[:id]).first
  @lines = Line.where(scripts_id: params[:id])
  @contributors = Contributor.where(scripts_id: params[:id])
  @presentation = service.get_presentation(@script.presentation_id)
  @thumbnails = Array[]
  @presentation.slides.each_with_index do |slide, i|
    @thumbnails.push(service.get_presentation_page_thumbnail(
      @script.presentation_id,
      slide.object_id_prop,
      thumbnail_properties_thumbnail_size: 'SMALL')
      .content_url)
  end
  erb :edit
end

get '/update/:id/auto-save' do
  line = Line.where(scripts_id: params[:id], order_num: params[:element_id])[0]
  if params[:role_body] == 'role'
    line.contributors_id = Contributor.find_by(name: params[:input_value]).id
  elsif params[:role_body] == 'body'
    line.body = params[:input_value]
  end
  line.save
end

get '/cardview' do
  if !current_user.nil?
    @scripts = Script.where(user_id: current_user.id)
    erb :cardview
  elsif
    redirect '/'
  end
end

get '/delete/:id' do
  script = Script.find(params[:id])
  script.destroy
  redirect '/'
end

def getPresentationId(url)
  idx = url.index("/presentation/d/").to_i + 16
  presentation_id = url[(idx),44]
  return presentation_id
end