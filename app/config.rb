configure do
  root = File.expand_path(File.dirname(__FILE__) + '../')
  set_option :views, File.join(root, 'app', 'views')

  # Load the configuration file.
  # if !File.exist?('config.yml')
  #   puts "There's no configuration file at config.yml!"
  #   exit!
  # end
  # CONFIG = YAML.load_file('config.yml')

end