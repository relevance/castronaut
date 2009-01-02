files = ["MIT-LICENSE", "Rakefile", "README.textile", "castronaut.rb", "bin/castronaut"]
files << Dir["lib/**/*", "app/**/*", "spec/**/*", "config/**/*",  "vendor/**/*"]

Gem::Specification.new do |s|
  s.name = 'castronaut'
  s.version = "0.5.3"
  s.summary = 'CAS Server'
  s.description = "CAS Server"
  s.files = files.flatten
  s.require_path = 'lib'
  s.has_rdoc = false
  s.extra_rdoc_files = []
  s.rdoc_options = []
  s.bindir = 'bin'
  s.default_executable = 'castronaut'
  s.executables = ["castronaut"]
  s.author = 'Relevance Inc'
  s.email = 'opensource@thinkrelevance.com'
  s.homepage = 'http://github.com/relevance/castronaut'
end
