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

  FileUtils.mkdir_p('db') unless File.exist?('db')

  ActiveRecord::Base.establish_connection(
    $cas_config.cas_database.each do |key,value|
      "#{key.to_sym} => #{value.to_s}"
    end
  )

  ActiveRecord::Base.logger = Logger.new(STDERR)
  ActiveRecord::Base.colorize_logging = false
  ActiveRecord::Migrator.migrate('lib/castronaut/db', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
end
