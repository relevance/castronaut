configure do
  root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'app'))
  app_file = "#{root}/controllers/application.rb"
  views = "#{root}/views"
  pub_dir = "#{root}/public"

  Castronaut.logger.debug "Sinatra Config - setting root path to #{root}"
  Castronaut.logger.debug "Sinatra Config - setting views path to #{views}"
  Castronaut.logger.debug "Sinatra Config - setting public path to #{pub_dir}"

  set :root,          root
  set :app_file,      app_file
  set :views,         views
  set :public,        pub_dir
  set :logging,       true
  set :raise_errors,  true
end
