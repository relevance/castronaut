configure do
  root = File.expand_path(File.join(File.dirname(__FILE__), '..', 'app'))
  views = "#{root}/views"
  pub_dir = "#{root}/public"

  $cas_config.logger.debug "Sinatra Config - setting root path to #{root}"
  $cas_config.logger.debug "Sinatra Config - setting views path to #{views}"
  $cas_config.logger.debug "Sinatra Config - setting public path to #{pub_dir}"

  set_options :root => root,
              :views => views,
              :public => pub_dir

end