require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'pry' if development?
require 'sinatra/activerecord'
require './models.rb'
require './googleslide.rb'

service = Google::Apis::SlidesV1::SlidesService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# https://docs.google.com/presentation/d/1DzieWq9aHR5_g_Cpnd5GtFNIfBosuwU9EXx6RwXjXCo/edit#slide=id.g9a70d324ed_2_50

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

# post '/test' do
#   @presentation_id = getPresentationId(params[:test_url])
#   redirect '/'
# end

get '/' do
  # presentation_id = "1DzieWq9aHR5_g_Cpnd5GtFNIfBosuwU9EXx6RwXjXCo"
  # page_object_id = 'g9a70d324ed_2_66'
  # @presentation = service.get_presentation(presentation_id)
  # @page = service.get_presentation_page(presentation_id, page_object_id)
  # @thumbnail = service.get_presentation_page_thumbnail(presentation_id, page_object_id, thumbnail_properties_thumbnail_size: 'SMALL')

  if !current_user.nil?
    @scripts = Script.where(user_id: current_user.id)
  end
  erb :index

  # <% @presentation.slides.each_with_index do |slide, i| %>
  # 	<%= slide.page_elements.count %>
  # <h3>The title of this presentation is <%= @presentation.title %></h3>
	# 	<h3>This presentation contains <%= @presentation.slides.count %> slides</h3>
	# 	<p><%= @page %> </p>
	# 	<p><%= @thumbnail %> </p>

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
    binding.pry
  end
  redirect '/'
end

post '/newScript' do
  if !current_user.nil?
    ctbt_count = params[:ctbt_count].to_i
    url = params[:presentation_url]
    presentation_id = getPresentationId(url)
    script = Script.create!(
      user_id: current_user.id,
      title: params[:title],
      description: params[:description],
      keyword: params[:keyword],
      presentation_id: presentation_id
    )
    ctbt_count.times do |i|
      param_name = 'ctbt_'+ i.to_s
      name = params[param_name]
      contributor = Contributor.create!(
        name: name,
        scripts_id: script.id
      )
      # binding.pry
    end

    # # get presentation slide count
    presentation = service.get_presentation(script.presentation_id)
    # # create lines for each slides
    presentation.slides.each_with_index do |page, i|
      line = Line.create!(
        scripts_id: script.id,
        contributors_id: Contributor.where(scripts_id: script.id).first.id,
        body: ""
      )
    end
  end
  redirect '/'
end

get '/view/:id' do
  @script = Script.where(id: params[:id]).first
  @lines = Line.where(scripts_id: params[:id])
  @contributors = Contributor.where(scripts_id: params[:id])
  @presentation = service.get_presentation(@script.presentation_id)
  @thumbnails = Array[]

  @presentation.slides.each_with_index do |slide, i|
    # @urls.push(script.object_id_prop)
    @thumbnails.push(service.get_presentation_page_thumbnail(@script.presentation_id, slide.object_id_prop, thumbnail_properties_thumbnail_size: 'SMALL').content_url)
  end
  # @presentation = service.get_presentation(@presentation_id)
  # @page = service.get_presentation_page(@scripts.presentation_id, page_object_id)
  # @thumbnail = service.get_presentation_page_thumbnail(presentation_id, page_object_id, thumbnail_properties_thumbnail_size: 'SMALL')
  # binding.pry
  erb :view
end

get '/edit/:id' do
  @script = Script.where(id: params[:id]).first
  @lines = Line.where(scripts_id: params[:id])
  @contributors = Contributor.where(scripts_id: params[:id])
  @presentation = service.get_presentation(@script.presentation_id)
  @thumbnails = Array[]

  @presentation.slides.each_with_index do |slide, i|
    # @urls.push(script.object_id_prop)
    @thumbnails.push(service.get_presentation_page_thumbnail(@script.presentation_id, slide.object_id_prop, thumbnail_properties_thumbnail_size: 'SMALL').content_url)
  end
  # @presentation.slides.each_with_index do |slide, i|
  #   @thumbnail = service.get_presentation_page_thumbnail(script.presentation_id,
  # end
  # binding.pry
  erb :edit
end

get '/update/:id/auto-save' do
  if params[:role_body] == 'role'
    line = Line.find(params[:id]).contributors_id
    line.review = Contributor.find_by(name: params[:input_value]).id
    line.save
  elsif params[:role_body] == 'body'
    line = Line.find(params[:id]).body
    line.review = params[:input_value]
    line.save
  end
end

def getPresentationId(url)
  idx = url.index("/presentation/d/").to_i + 16
  presentation_id = url[(idx),44]
  return presentation_id
end