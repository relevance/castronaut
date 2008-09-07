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

  $cas_config.cas_adapter.each do |key,value|
    if key == "database"
      ActiveRecord::Base.establish_connection(
        value.each do |key, value|
          "#{key.to_sym} => #{value.to_s}"
        end
      )
    end
  end

  ActiveRecord::Base.logger = Logger.new(STDERR)
  ActiveRecord::Migrator.migrate('lib/castronaut/db', ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
end
